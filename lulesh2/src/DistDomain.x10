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

import x10.util.resilient.iterative.Snapshottable;
import x10.util.resilient.iterative.DistObjectSnapshot;
import x10.regionarray.Dist;

class DistDomain implements Snapshottable {
    static VERBOSE = System.getenv("LULESH_VERBOSE") != null;
    public var domainPlh:PlaceLocalHandle[Domain];
    public var places:PlaceGroup;
    
    public def this(dPlh:PlaceLocalHandle[Domain], places:PlaceGroup) {
        this.domainPlh = dPlh;
        this.places = places;
    }

    public def remake(newPg:PlaceGroup, opts:CommandLineOptions) {
        val oldPlaces = places;
        PlaceLocalHandle.destroy(oldPlaces, domainPlh, (Place)=>true);
    
        val numPlaces = newPg.size();
    
        val placesPerSide = Math.cbrt((numPlaces as Double) + 0.5) as Int;
        if  (placesPerSide <= 0 || placesPerSide*placesPerSide*placesPerSide != numPlaces as Int) {
            throw new Exception("Num of restore processors must be a cube of an integer (1, 8, 27, ...)");
        }
        places = newPg;
        domainPlh = PlaceLocalHandle.make[Domain](places, 
            () => new Domain(opts.nx, opts.numReg, opts.balance, opts.cost, placesPerSide, places));
    }
    
    public def makeSnapshot():DistObjectSnapshot {
        val snapshot = DistObjectSnapshot.make();
        finish ateach(pl in Dist.makeUnique(places)){
             val i = places.indexOf(here);
             val localDomain = domainPlh();
             val domainSnapInfo = new DomainSnapshot(localDomain);
             snapshot.save(i, domainSnapInfo);
        }
        return snapshot;
    }
    
    public def restoreSnapshot(snapshot:DistObjectSnapshot) {
        finish ateach(Dist.makeUnique(places)) {
            val i = places.indexOf(here);
            val storedDomain = snapshot.load(i) as DomainSnapshot;
            storedDomain.populateDomain(domainPlh());
        }
    }
    
    public def makeSnapshot_local(snapshot:DistObjectSnapshot) {
        if (VERBOSE) Console.OUT.println(here + " start make snapshot local >>>>>>>");
        val i = places.indexOf(here);
        val localDomain = domainPlh();
        val domainSnapInfo = new DomainSnapshot(localDomain);
        snapshot.save(i, domainSnapInfo);
        if (VERBOSE)  Console.OUT.println(here + " end make snapshot local >>>>>>>");
    }
    
    public def restoreSnapshot_local(snapshot:DistObjectSnapshot) {
        if (VERBOSE) Console.OUT.println(here + " start restore local #####");
        val i = places.indexOf(here);
        val storedDomain = snapshot.load(i) as DomainSnapshot;
        storedDomain.populateDomain(domainPlh());
        if (VERBOSE) Console.OUT.println(here + " end restore local #####");
    }
}
// vim:tabstop=4:shiftwidth=4:expandtab
