(*--build-config
    options:--admit_fsi Set --z3timeout 10;
    variables:LIB=../../lib;
    other-files:$LIB/ext.fst $LIB/set.fsi $LIB/heap.fst $LIB/st.fst $LIB/list.fst  stack.fst listset.fst st3.fst $LIB/constr.fst word.fst mvector.fsi
  --*)

module MVector
open StructuredMem
open MachineWord
open Seq
open Heap

type vector (a:Type) (n:nat) = (index:nat{index<n} -> Tot a)

let updateIndex 'a #n f index newV =
  (fun indx -> if (indx= index) then newV else f indx)

let atIndex 'a #n f index  =
   f index

(* When F* complains that effect ALL and StSTATE cannot be combined,
  see whether you missed a Tot somewhere.
  Is there a way to make Tot the default effect, instead of ALL
*)

(*val readIndex :  #a:Type -> #n:nat -> r:(ref (vector a n))
  -> index:nat{index<n} -> Mem a (fun m -> b2t (refExistsInMem r m)) (fun _ _ _-> True)*)
let readIndex 'a #n r index =
  let rv = (memread r) in (atIndex rv index)

(*Can one reinclude the types from the FSI file?*)

(*val updIndex :  #a:Type -> #n:nat -> r:(ref (vector a n))
  -> index:nat{index<n} -> a ->
 Mem unit (fun m -> b2t (refExistsInMem r m)) (fun _ _ _-> True)*)
let updIndex 'a #n r index newV =
  let rv = (memread r) in
  memwrite r (updateIndex rv index newV)
