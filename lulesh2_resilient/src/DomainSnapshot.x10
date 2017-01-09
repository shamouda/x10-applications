/*
 *  This file is part of the X10 project (http://x10-lang.org).
 *
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 *
 *  (C) Copyright IBM Corporation 2015.
 */

import x10.util.resilient.localstore.Cloneable;
import x10.util.HashMap;

class DomainSnapshot implements Cloneable {
    private var data:Rail[Double];
/*    
public var xdd:Rail[Double];   numNode
public var ydd:Rail[Double];   numNode
public var zdd:Rail[Double];   numNode
public var fx:Rail[Double];  numNode
public var fy:Rail[Double];  numNode
public var fz:Rail[Double];  numNode

public var delv:Rail[Double];    numElem
public var vdov:Rail[Double];    numElem
public var arealg:Rail[Double];  numElem
public var ss:Rail[Double];      numElem
*/

    public def this(domain:Domain) {
        val numNode = domain.x.size as Long;
        val numElem = domain.e.size as Long;        
        data = new Rail[Double](12*numNode + 10*numElem + 8);
        var srcOff:Long = 0;
        data(srcOff++) = numNode;
        data(srcOff++) = numElem;
        
        data(srcOff++) = domain.dtcourant;
        data(srcOff++) = domain.dthydro;
        data(srcOff++) = domain.cycle;
        data(srcOff++) = domain.time;
        data(srcOff++) = domain.deltatime;
        
        data(srcOff++) = domain.startTimeMillis;
        
        Rail.copy(domain.x , 0, data, srcOff, numNode); srcOff += numNode;
        Rail.copy(domain.y , 0, data, srcOff, numNode); srcOff += numNode;
        Rail.copy(domain.z , 0, data, srcOff, numNode); srcOff += numNode;
        Rail.copy(domain.xd, 0, data, srcOff, numNode); srcOff += numNode;
        Rail.copy(domain.yd, 0, data, srcOff, numNode); srcOff += numNode;
        Rail.copy(domain.zd, 0, data, srcOff, numNode); srcOff += numNode;
        
        Rail.copy(domain.fx , 0, data, srcOff, numNode); srcOff += numNode; //1
        Rail.copy(domain.fy , 0, data, srcOff, numNode); srcOff += numNode; //2
        Rail.copy(domain.fz , 0, data, srcOff, numNode); srcOff += numNode; //3
        
        Rail.copy(domain.xdd , 0, data, srcOff, numNode); srcOff += numNode; //4
        Rail.copy(domain.ydd , 0, data, srcOff, numNode); srcOff += numNode; //5
        Rail.copy(domain.zdd , 0, data, srcOff, numNode); srcOff += numNode; //6
        
        Rail.copy(domain.e , 0, data, srcOff, numElem); srcOff += numElem;
        Rail.copy(domain.p , 0, data, srcOff, numElem); srcOff += numElem;
        Rail.copy(domain.q , 0, data, srcOff, numElem); srcOff += numElem;
        Rail.copy(domain.ql, 0, data, srcOff, numElem); srcOff += numElem;
        Rail.copy(domain.qq, 0, data, srcOff, numElem); srcOff += numElem;
        Rail.copy(domain.v , 0, data, srcOff, numElem); srcOff += numElem;
        
        
        Rail.copy(domain.delv , 0, data, srcOff, numElem); srcOff += numElem;  //4
        Rail.copy(domain.vdov , 0, data, srcOff, numElem); srcOff += numElem; //5
        Rail.copy(domain.arealg , 0, data, srcOff, numElem); srcOff += numElem; //6
        Rail.copy(domain.ss , 0, data, srcOff, numElem);  //7
        
    }
    
    public def this(allDate:Rail[Double]) {
        this.data = allDate;
    }

    public def clone():Cloneable {
        return new DomainSnapshot(new Rail[Double](data));
    }
       
    public def populateDomain(domain:Domain){
        var srcOff:Long = 0;   
        val numNode = data(srcOff++) as Long;
        val numElem = data(srcOff++) as Long;
        
        domain.dtcourant = data(srcOff++);
        domain.dthydro = data(srcOff++);
        domain.cycle = data(srcOff++) as Int;
        domain.time = data(srcOff++);
        domain.deltatime = data(srcOff++);
        
        domain.startTimeMillis = data(srcOff++) as Long;
        
        Rail.copy(data, srcOff, domain.x , 0, numNode); srcOff += numNode;
        Rail.copy(data, srcOff, domain.y , 0, numNode); srcOff += numNode;
        Rail.copy(data, srcOff, domain.z , 0, numNode); srcOff += numNode;
        Rail.copy(data, srcOff, domain.xd, 0, numNode); srcOff += numNode;
        Rail.copy(data, srcOff, domain.yd, 0, numNode); srcOff += numNode;
        Rail.copy(data, srcOff, domain.zd, 0, numNode); srcOff += numNode;
        
        Rail.copy(data, srcOff, domain.fx , 0, numNode); srcOff += numNode; //1
        Rail.copy(data, srcOff, domain.fy , 0, numNode); srcOff += numNode; //2
        Rail.copy(data, srcOff, domain.fz , 0, numNode); srcOff += numNode; //3
        Rail.copy(data, srcOff, domain.xdd , 0, numNode); srcOff += numNode; //1
        Rail.copy(data, srcOff, domain.ydd , 0, numNode); srcOff += numNode; //2
        Rail.copy(data, srcOff, domain.zdd , 0, numNode); srcOff += numNode; //3            
        
        Rail.copy(data, srcOff, domain.e , 0, numElem); srcOff += numElem;
        Rail.copy(data, srcOff, domain.p , 0, numElem); srcOff += numElem;
        Rail.copy(data, srcOff, domain.q , 0, numElem); srcOff += numElem;
        Rail.copy(data, srcOff, domain.ql, 0, numElem); srcOff += numElem;
        Rail.copy(data, srcOff, domain.qq, 0, numElem); srcOff += numElem;
        Rail.copy(data, srcOff, domain.v , 0, numElem); srcOff += numElem;
        
        Rail.copy(data, srcOff, domain.delv , 0, numElem); srcOff += numElem; //4
        Rail.copy(data, srcOff, domain.vdov , 0, numElem); srcOff += numElem; //5
        Rail.copy(data, srcOff, domain.arealg , 0, numElem); srcOff += numElem; //6
        Rail.copy(data, srcOff, domain.ss , 0, numElem); //7
        
    }
}
// vim:tabstop=4:shiftwidth=4:expandtab
