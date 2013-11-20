package comd;

/*
 *  This file is part of the X10 project (http://x10-lang.org).
 * 
 *  This file is licensed to You under the Eclipse Public License (EPL);
 *  You may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *      http://www.opensource.org/licenses/eclipse-1.0.php
 * 
 *  (C) Copyright IBM Corporation 2006-2010.
 */

import x10.util.concurrent.Monitor;

import x10.compiler.Pinned;

/**
 * Boolean latch.
 * Inherited look/unlock/tryLock method from superclass can be used.
 */
@Pinned public class Latch2 extends Monitor implements ()=>Boolean {
/**
 * Latch is initially unset
 */
public def this() { super(); }

private def this(Any) {
    throw new UnsupportedOperationException("Cannot deserialize "+typeName());
}

private var state:boolean = false;

/**
 * Set the latch
 */
public def release():void {
    lock();
    state = true;
    super.release();
}

/**
 * Wait for the latch to be set
 * Return instantly if it already is
 */
public def await():void {
    Runtime.ensureNotInAtomic();
    // avoid locking if state == true
    if (!state) {
        lock();
        while (!state) super.await();
        unlock();
    }
}

public def sync():void {
    Runtime.ensureNotInAtomic();
    lock();
    if (!state) {
        while (!state) super.await();
    }
    state = false;
    unlock();
}

/**
 * Check the latch state without blocking
 */
public operator this():boolean = state;
}
