import x10.array.*;
import x10.util.concurrent.AtomicDouble;

/************************************************************
* program to solve a finite difference 
* discretization of Helmholtz equation :  
* (d2/dx2)u + (d2/dy2)u - alpha u = f 
* using Jacobi iterative method. 
*
* Modified: Sanjiv Shah,       Kuck and Associates, Inc. (KAI), 1998
* Author:   Joseph Robicheaux, Kuck and Associates, Inc. (KAI), 1998
* This X10 version by David Grove, IBM Research, was translated in September 2013
* from the C translation written by Chunhua Liao, University of Houston, Jan, 2005.
* 
* Input :  n - grid dimension in x direction 
*          m - grid dimension in y direction
*          alpha - Helmholtz constant (always greater than 0.0)
*          tol   - error tolerance for iterative solver
*          relax - Successive over relaxation parameter
*          mits  - Maximum iterations for iterative solver
*
* On output 
*       : u(n,m) - Dependent variable (solutions)
*       : f(n,m) - Right hand side function 
*************************************************************/

public class JacobiOMP {
    static val relax = 1.0;
    static val alpha = 0.0543;

    val n:long;
    val m:long;
    val u:Array_2[double]{self!=null};
    val uold:Array_2[double]{self!=null};
    val f:Array_2[double];

    val P:long = x10.xrx.Runtime.NTHREADS;

    public static def main(args:Rail[String]) {
        var size:Long = 1000;
        if (args.size > 0) {
            size = Long.parse(args(0));
        }
        val n = size;
        val m = size;
        val tol=0.0000000001;
        val mits=5000;

        val jb = new JacobiOMP(m, n);
        Console.OUT.println("Jacobi iteration with OMPBarrier using "+jb.P+" threads...");

        val start = System.nanoTime();
        val iters = jb.jacobi(tol, mits);
        val end = System.nanoTime();

        Console.OUT.println("------------------------");
        val timeInMillis = (end-start)/1E6;

        jb.errorCheck();

        Console.OUT.printf("Jacobi size: %d X10_NTHREADS: %d total time: %.3f s (per iter: %.3f ms)\n", size, jb.P, timeInMillis/1E3, timeInMillis/iters);
    }

    /** 
     * Initializes data assuming exact solution is u(x,y) = (1-x^2)*(1-y^2)
     */
    def this(n:long, m:long) {
        val dx = 2.0 / (n-1);
        val dy = 2.0 / (m-1);
        this.m = m;
        this.n = n;
        this.u = new Array_2[double](n,m);
        this.uold = new Array_2[double](n,m);
	this.f = new Array_2[double](n, m, (i:long,j:long) => {
            val xx = (-1.0 + dx * (i-1)) as int;
            val yy = (-1.0 + dy * (j-1)) as int;
            -1.0*alpha *(1.0-xx*xx)*(1.0-yy*yy) -2.0*(1.0-xx*xx)-2.0*(1.0-yy*yy)
        });
    }

   /******************************************************************
    * Subroutine HelmholtzJ
    * Solves Poisson equation on rectangular grid assuming : 
    * (1) Uniform discretization in each direction, and 
    * (2) Dirichlet boundary conditions 
    * 
    * Jacobi method is used in this routine 
    *
    * Input : n,m   Number of grid points in the X/Y directions 
    *         dx,dy Grid spacing in the X/Y directions 
    *         alpha Helmholtz eqn. coefficient 
    *         omega Relaxation factor 
    *         f(n,m) Right hand side function 
    *         u(n,m) Dependent variable/Solution
    *         tol    Tolerance for iterative solver 
    *         maxit  Maximum number of iterations 
    *
    * Output : u(n,m) - Solution 
    *****************************************************************/
    def jacobi(tol:double, mits:long) {
        val omega=relax;
        val dx = 2.0 / (n-1);
        val dy = 2.0 / (m-1);

        // Initialize coefficients
        val ax = 1.0/(dx*dx); /* X-direction coef */
        val ay = 1.0/(dy*dy); /* Y-direction coef */
        val b  = -2.0/(dx*dx)-2.0/(dy*dy) - alpha; /* Central coeff */ 

        val residual = new Cell[Double](10.0 * tol);
        val error = new Rail[Double](P, 0.0);
        val k = new Cell[Long](0);

        val barrier = new OMPBarrier(P as int);

        finish {
            val is = new Rail[DenseIterationSpace_1](P, (i:long)=>BlockingUtils.partitionBlock(1,n-2,P, i));
            var id:int = 0n;
            for (block in is) {
                val myId = id++;
                async {
                    barrier.register();
                    while ((k()<mits)&&(residual()>tol)) {
                        if (barrier.single()) {
                            Array.swap(u, uold);
                            barrier.multi();
                        }

                        var my_error:double = 0.0;
                        for ([i] in block) {
                            for (j in 1..(m-2)) {
                                val resid = (ax*(uold(i-1, j) + uold(i+1, j)) +
                                             ay*(uold(i, j-1) + uold(i, j+1)) + 
                                             b * uold(i, j) - f(i, j))/b;  
                                u(i, j) = uold(i, j) - omega * resid;  
                                my_error += resid*resid;   
                             }
                        }
                        error(myId) = my_error;

                        if (barrier.single()) {
                            k() += 1;
                            my_error = 0.0;
                            for (i in 0..(P-1)) my_error += error(i);
                            residual() = Math.sqrt(my_error)/(n*m);
                            if (k()%500==0) { Console.OUT.println("Finished "+k()+" iteration."); }
                            barrier.multi();
                        }
                    }
                }
            }
        }

        Console.OUT.println("Total Number of Iterations:"+k());
        Console.OUT.printf("Residual:%E\n", residual());

        return k();
    }


    /************************************************************
    * Checks error between numerical and exact solution 
    ************************************************************/ 
    def errorCheck() {
        val dx = 2.0 / (n-1);
        val dy = 2.0 / (m-1);
        var error:double = 0.0 ;

        for (i in 0..(n-1)) {
            for (j in 0..(m-1)) {
               val xx = -1.0 + dx * (i-1);
               val yy = -1.0 + dy * (j-1);
               val temp  = u(i,j) - (1.0-xx*xx)*(1.0-yy*yy);
               error = error + temp*temp; 
            }
        }
        error = Math.sqrt(error)/(n*m);
        Console.OUT.println("Solution Error :"+error);
    }
}
