(*
   Copyright 2008-2018 Microsoft Research

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)
module Unit1.UnificationTests
assume type t : int -> Type
assume val f: int -> Tot int
assume val g: #x:int -> t (f x) -> Tot unit
let h1 (x: t (f 0)) = g x
let h2 (x: t ((fun x -> f (x - 1)) 1)) = g x

(****** test for unfolding of delta equational symbols begin ******)

type some_enum =
  | X
  | Y

let t_indexed (x:some_enum) =
  match x with
  | X -> nat
  | Y -> int

let t_inst_index = t_indexed X

assume val f_with_implicit (#x:some_enum) (u:t_indexed x) (v:t_indexed x) :t_indexed x

let g_calls_f (u v:t_inst_index) = f_with_implicit u v  //the implicit here is inferred by unfolding t_inst_index, which is delta_equational with some depth (2, i think)

(****** test for unfolding of delta equational symbols end ******)

(*
 * #923
 *)
assume val p_923: Type0
let t_923 () : Tot Type0 = unit -> Tot p_923
let f_923 (g: t_923 ()) : Tot p_923 = g ()

let u_923 () : Pure Type0 (requires True) (ensures (fun y -> True)) = unit -> Tot p_923
let h_923 (g: u_923 ()) : Tot p_923 =
  let g' : (unit -> Tot p_923) = g in g' ()

(*
 * #760
 *)
unfold let buf_760 (a:Type0) = l:list a { l == [] }
val test_760 : a:Type0 -> Tot (buf_760 a)
let test_760 a = admit #(buf_760 a) ()



module G = FStar.Ghost

assume type t_coercions1 : int -> Type0

assume val x_t1 : t_coercions1 100

assume val foo1 : #n:G.erased int -> $x:t_coercions1 (G.reveal n) -> unit

#set-options "--print_implicits"
let test_coercions1 () : unit = foo1 x_t1


assume type t_coercions2 : G.erased int -> Type0

assume val n_t2 : G.erased int
assume val x_t2 : t_coercions2 n_t2

assume val foo2 : #n:int -> $x:t_coercions2 (G.hide n) -> unit

let test_coercions2 () : unit = foo2 x_t2
