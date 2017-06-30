open Prims
type verify_mode =
  | VerifyAll
  | VerifyUserList
  | VerifyFigureItOut
let uu___is_VerifyAll: verify_mode -> Prims.bool =
  fun projectee  ->
    match projectee with | VerifyAll  -> true | uu____5 -> false
let uu___is_VerifyUserList: verify_mode -> Prims.bool =
  fun projectee  ->
    match projectee with | VerifyUserList  -> true | uu____10 -> false
let uu___is_VerifyFigureItOut: verify_mode -> Prims.bool =
  fun projectee  ->
    match projectee with | VerifyFigureItOut  -> true | uu____15 -> false
type map =
  (Prims.string FStar_Pervasives_Native.option,Prims.string
                                                 FStar_Pervasives_Native.option)
    FStar_Pervasives_Native.tuple2 FStar_Util.smap
type color =
  | White
  | Gray
  | Black
let uu___is_White: color -> Prims.bool =
  fun projectee  -> match projectee with | White  -> true | uu____25 -> false
let uu___is_Gray: color -> Prims.bool =
  fun projectee  -> match projectee with | Gray  -> true | uu____30 -> false
let uu___is_Black: color -> Prims.bool =
  fun projectee  -> match projectee with | Black  -> true | uu____35 -> false
type open_kind =
  | Open_module
  | Open_namespace
let uu___is_Open_module: open_kind -> Prims.bool =
  fun projectee  ->
    match projectee with | Open_module  -> true | uu____40 -> false
let uu___is_Open_namespace: open_kind -> Prims.bool =
  fun projectee  ->
    match projectee with | Open_namespace  -> true | uu____45 -> false
let check_and_strip_suffix:
  Prims.string -> Prims.string FStar_Pervasives_Native.option =
  fun f  ->
    let suffixes = [".fsti"; ".fst"; ".fsi"; ".fs"] in
    let matches =
      FStar_List.map
        (fun ext  ->
           let lext = FStar_String.length ext in
           let l = FStar_String.length f in
           let uu____70 =
             (l > lext) &&
               (let uu____82 = FStar_String.substring f (l - lext) lext in
                uu____82 = ext) in
           if uu____70
           then
             let uu____98 =
               FStar_String.substring f (Prims.parse_int "0") (l - lext) in
             FStar_Pervasives_Native.Some uu____98
           else FStar_Pervasives_Native.None) suffixes in
    let uu____110 = FStar_List.filter FStar_Util.is_some matches in
    match uu____110 with
    | (FStar_Pervasives_Native.Some m)::uu____116 ->
        FStar_Pervasives_Native.Some m
    | uu____120 -> FStar_Pervasives_Native.None
let is_interface: Prims.string -> Prims.bool =
  fun f  ->
    let uu____127 =
      FStar_String.get f ((FStar_String.length f) - (Prims.parse_int "1")) in
    uu____127 = 'i'
let is_implementation: Prims.string -> Prims.bool =
  fun f  -> let uu____138 = is_interface f in Prims.op_Negation uu____138
let list_of_option uu___83_149 =
  match uu___83_149 with
  | FStar_Pervasives_Native.Some x -> [x]
  | FStar_Pervasives_Native.None  -> []
let list_of_pair uu____165 =
  match uu____165 with
  | (intf,impl) ->
      FStar_List.append (list_of_option intf) (list_of_option impl)
let lowercase_module_name: Prims.string -> Prims.string =
  fun f  ->
    let uu____180 =
      let uu____182 = FStar_Util.basename f in
      check_and_strip_suffix uu____182 in
    match uu____180 with
    | FStar_Pervasives_Native.Some longname ->
        FStar_String.lowercase longname
    | FStar_Pervasives_Native.None  ->
        let uu____184 =
          let uu____185 = FStar_Util.format1 "not a valid FStar file: %s\n" f in
          FStar_Errors.Err uu____185 in
        raise uu____184
let build_map:
  Prims.string Prims.list ->
    (Prims.string FStar_Pervasives_Native.option,Prims.string
                                                   FStar_Pervasives_Native.option)
      FStar_Pervasives_Native.tuple2 FStar_Util.smap
  =
  fun filenames  ->
    let include_directories = FStar_Options.include_path () in
    let include_directories1 =
      FStar_List.map FStar_Util.normalize_file_path include_directories in
    let include_directories2 = FStar_List.unique include_directories1 in
    let cwd =
      let uu____199 = FStar_Util.getcwd () in
      FStar_Util.normalize_file_path uu____199 in
    let map1 = FStar_Util.smap_create (Prims.parse_int "41") in
    let add_entry key full_path =
      let uu____217 = FStar_Util.smap_try_find map1 key in
      match uu____217 with
      | FStar_Pervasives_Native.Some (intf,impl) ->
          let uu____237 = is_interface full_path in
          if uu____237
          then
            FStar_Util.smap_add map1 key
              ((FStar_Pervasives_Native.Some full_path), impl)
          else
            FStar_Util.smap_add map1 key
              (intf, (FStar_Pervasives_Native.Some full_path))
      | FStar_Pervasives_Native.None  ->
          let uu____255 = is_interface full_path in
          if uu____255
          then
            FStar_Util.smap_add map1 key
              ((FStar_Pervasives_Native.Some full_path),
                FStar_Pervasives_Native.None)
          else
            FStar_Util.smap_add map1 key
              (FStar_Pervasives_Native.None,
                (FStar_Pervasives_Native.Some full_path)) in
    FStar_List.iter
      (fun d  ->
         if FStar_Util.file_exists d
         then
           let files = FStar_Util.readdir d in
           FStar_List.iter
             (fun f  ->
                let f1 = FStar_Util.basename f in
                let uu____283 = check_and_strip_suffix f1 in
                match uu____283 with
                | FStar_Pervasives_Native.Some longname ->
                    let full_path =
                      if d = cwd then f1 else FStar_Util.join_paths d f1 in
                    let key = FStar_String.lowercase longname in
                    add_entry key full_path
                | FStar_Pervasives_Native.None  -> ()) files
         else
           (let uu____290 =
              let uu____291 =
                FStar_Util.format1 "not a valid include directory: %s\n" d in
              FStar_Errors.Err uu____291 in
            raise uu____290)) include_directories2;
    FStar_List.iter
      (fun f  ->
         let uu____296 = lowercase_module_name f in add_entry uu____296 f)
      filenames;
    map1
let enter_namespace: map -> map -> Prims.string -> Prims.bool =
  fun original_map  ->
    fun working_map  ->
      fun prefix1  ->
        let found = FStar_Util.mk_ref false in
        let prefix2 = Prims.strcat prefix1 "." in
        (let uu____314 =
           let uu____316 = FStar_Util.smap_keys original_map in
           FStar_List.unique uu____316 in
         FStar_List.iter
           (fun k  ->
              if FStar_Util.starts_with k prefix2
              then
                let suffix =
                  FStar_String.substring k (FStar_String.length prefix2)
                    ((FStar_String.length k) - (FStar_String.length prefix2)) in
                let filename =
                  let uu____347 = FStar_Util.smap_try_find original_map k in
                  FStar_Util.must uu____347 in
                (FStar_Util.smap_add working_map suffix filename;
                 FStar_ST.write found true)
              else ()) uu____314);
        FStar_ST.read found
let string_of_lid: FStar_Ident.lident -> Prims.bool -> Prims.string =
  fun l  ->
    fun last1  ->
      let suffix =
        if last1 then [(l.FStar_Ident.ident).FStar_Ident.idText] else [] in
      let names =
        let uu____385 =
          FStar_List.map (fun x  -> x.FStar_Ident.idText) l.FStar_Ident.ns in
        FStar_List.append uu____385 suffix in
      FStar_String.concat "." names
let lowercase_join_longident:
  FStar_Ident.lident -> Prims.bool -> Prims.string =
  fun l  ->
    fun last1  ->
      let uu____397 = string_of_lid l last1 in
      FStar_String.lowercase uu____397
let namespace_of_lid: FStar_Ident.lident -> Prims.string =
  fun l  ->
    let uu____402 = FStar_List.map FStar_Ident.text_of_id l.FStar_Ident.ns in
    FStar_String.concat "_" uu____402
let check_module_declaration_against_filename:
  FStar_Ident.lident -> Prims.string -> Prims.unit =
  fun lid  ->
    fun filename  ->
      let k' = lowercase_join_longident lid true in
      let uu____413 =
        let uu____414 =
          let uu____415 =
            let uu____416 =
              let uu____418 = FStar_Util.basename filename in
              check_and_strip_suffix uu____418 in
            FStar_Util.must uu____416 in
          FStar_String.lowercase uu____415 in
        uu____414 <> k' in
      if uu____413
      then
        let uu____419 = string_of_lid lid true in
        FStar_Util.print2_warning
          "Warning: the module declaration \"module %s\" found in file %s does not match its filename. Dependencies will be incorrect.\n"
          uu____419 filename
      else ()
exception Exit
let uu___is_Exit: Prims.exn -> Prims.bool =
  fun projectee  -> match projectee with | Exit  -> true | uu____425 -> false
let hard_coded_dependencies:
  Prims.string ->
    (FStar_Ident.lident,open_kind) FStar_Pervasives_Native.tuple2 Prims.list
  =
  fun filename  ->
    let filename1 = FStar_Util.basename filename in
    let corelibs =
      let uu____436 = FStar_Options.prims_basename () in
      let uu____437 =
        let uu____439 = FStar_Options.pervasives_basename () in
        let uu____440 =
          let uu____442 = FStar_Options.pervasives_native_basename () in
          [uu____442] in
        uu____439 :: uu____440 in
      uu____436 :: uu____437 in
    if FStar_List.mem filename1 corelibs
    then []
    else
      [(FStar_Parser_Const.fstar_ns_lid, Open_namespace);
      (FStar_Parser_Const.prims_lid, Open_module);
      (FStar_Parser_Const.pervasives_lid, Open_module)]
let collect_one:
  (Prims.string,Prims.bool FStar_ST.ref) FStar_Pervasives_Native.tuple2
    Prims.list ->
    verify_mode ->
      Prims.bool -> map -> Prims.string -> Prims.string Prims.list
  =
  fun verify_flags  ->
    fun verify_mode  ->
      fun is_user_provided_filename  ->
        fun original_map  ->
          fun filename  ->
            let deps = FStar_Util.mk_ref [] in
            let add_dep d =
              let uu____496 =
                let uu____497 =
                  let uu____498 = FStar_ST.read deps in
                  FStar_List.existsML (fun d'  -> d' = d) uu____498 in
                Prims.op_Negation uu____497 in
              if uu____496
              then
                let uu____505 =
                  let uu____507 = FStar_ST.read deps in d :: uu____507 in
                FStar_ST.write deps uu____505
              else () in
            let working_map = FStar_Util.smap_copy original_map in
            let record_open_module let_open lid =
              let key = lowercase_join_longident lid true in
              let uu____534 = FStar_Util.smap_try_find working_map key in
              match uu____534 with
              | FStar_Pervasives_Native.Some pair ->
                  (FStar_List.iter
                     (fun f  ->
                        let uu____557 = lowercase_module_name f in
                        add_dep uu____557) (list_of_pair pair);
                   true)
              | FStar_Pervasives_Native.None  ->
                  let r = enter_namespace original_map working_map key in
                  (if Prims.op_Negation r
                   then
                     (if let_open
                      then
                        raise
                          (FStar_Errors.Err
                             "let-open only supported for modules, not namespaces")
                      else
                        (let uu____565 = string_of_lid lid true in
                         FStar_Util.print2_warning
                           "Warning: in %s: no modules in namespace %s and no file with that name either\n"
                           filename uu____565))
                   else ();
                   false) in
            let record_open_namespace error_msg lid =
              let key = lowercase_join_longident lid true in
              let r = enter_namespace original_map working_map key in
              if Prims.op_Negation r
              then
                match error_msg with
                | FStar_Pervasives_Native.Some e ->
                    raise (FStar_Errors.Err e)
                | FStar_Pervasives_Native.None  ->
                    let uu____579 = string_of_lid lid true in
                    FStar_Util.print1_warning
                      "Warning: no modules in namespace %s and no file with that name either\n"
                      uu____579
              else () in
            let record_open let_open lid =
              let uu____588 = record_open_module let_open lid in
              if uu____588
              then ()
              else
                (let msg =
                   if let_open
                   then
                     FStar_Pervasives_Native.Some
                       "let-open only supported for modules, not namespaces"
                   else FStar_Pervasives_Native.None in
                 record_open_namespace msg lid) in
            let record_open_module_or_namespace uu____599 =
              match uu____599 with
              | (lid,kind) ->
                  (match kind with
                   | Open_namespace  ->
                       record_open_namespace FStar_Pervasives_Native.None lid
                   | Open_module  ->
                       let uu____604 = record_open_module false lid in ()) in
            let record_module_alias ident lid =
              let key = FStar_String.lowercase (FStar_Ident.text_of_id ident) in
              let alias = lowercase_join_longident lid true in
              let uu____614 = FStar_Util.smap_try_find original_map alias in
              match uu____614 with
              | FStar_Pervasives_Native.Some deps_of_aliased_module ->
                  FStar_Util.smap_add working_map key deps_of_aliased_module
              | FStar_Pervasives_Native.None  ->
                  let uu____641 =
                    let uu____642 =
                      FStar_Util.format1
                        "module not found in search path: %s\n" alias in
                    FStar_Errors.Err uu____642 in
                  raise uu____641 in
            let record_lid lid =
              let try_key key =
                let uu____651 = FStar_Util.smap_try_find working_map key in
                match uu____651 with
                | FStar_Pervasives_Native.Some pair ->
                    FStar_List.iter
                      (fun f  ->
                         let uu____673 = lowercase_module_name f in
                         add_dep uu____673) (list_of_pair pair)
                | FStar_Pervasives_Native.None  ->
                    let uu____678 =
                      ((FStar_List.length lid.FStar_Ident.ns) >
                         (Prims.parse_int "0"))
                        && (FStar_Options.debug_any ()) in
                    if uu____678
                    then
                      let uu____685 =
                        FStar_Range.string_of_range
                          (FStar_Ident.range_of_lid lid) in
                      let uu____686 = string_of_lid lid false in
                      FStar_Util.print2_warning
                        "%s (Warning): unbound module reference %s\n"
                        uu____685 uu____686
                    else () in
              let uu____689 = lowercase_join_longident lid false in
              try_key uu____689 in
            let auto_open = hard_coded_dependencies filename in
            FStar_List.iter record_open_module_or_namespace auto_open;
            (let num_of_toplevelmods =
               FStar_Util.mk_ref (Prims.parse_int "0") in
             let rec collect_file uu___84_761 =
               match uu___84_761 with
               | modul::[] -> collect_module modul
               | modules ->
                   (FStar_Util.print1_warning
                      "Warning: file %s does not respect the one module per file convention\n"
                      filename;
                    FStar_List.iter collect_module modules)
             and collect_module uu___85_767 =
               match uu___85_767 with
               | FStar_Parser_AST.Module (lid,decls) ->
                   (check_module_declaration_against_filename lid filename;
                    if
                      (FStar_List.length lid.FStar_Ident.ns) >
                        (Prims.parse_int "0")
                    then
                      (let uu____780 =
                         let uu____781 = namespace_of_lid lid in
                         enter_namespace original_map working_map uu____781 in
                       ())
                    else ();
                    (match verify_mode with
                     | VerifyAll  ->
                         let uu____784 = string_of_lid lid true in
                         FStar_Options.add_verify_module uu____784
                     | VerifyFigureItOut  ->
                         if is_user_provided_filename
                         then
                           let uu____785 = string_of_lid lid true in
                           FStar_Options.add_verify_module uu____785
                         else ()
                     | VerifyUserList  ->
                         FStar_List.iter
                           (fun uu____794  ->
                              match uu____794 with
                              | (m,r) ->
                                  let uu____802 =
                                    let uu____803 =
                                      let uu____804 = string_of_lid lid true in
                                      FStar_String.lowercase uu____804 in
                                    (FStar_String.lowercase m) = uu____803 in
                                  if uu____802
                                  then FStar_ST.write r true
                                  else ()) verify_flags);
                    collect_decls decls)
               | FStar_Parser_AST.Interface (lid,decls,uu____810) ->
                   (check_module_declaration_against_filename lid filename;
                    if
                      (FStar_List.length lid.FStar_Ident.ns) >
                        (Prims.parse_int "0")
                    then
                      (let uu____821 =
                         let uu____822 = namespace_of_lid lid in
                         enter_namespace original_map working_map uu____822 in
                       ())
                    else ();
                    (match verify_mode with
                     | VerifyAll  ->
                         let uu____825 = string_of_lid lid true in
                         FStar_Options.add_verify_module uu____825
                     | VerifyFigureItOut  ->
                         if is_user_provided_filename
                         then
                           let uu____826 = string_of_lid lid true in
                           FStar_Options.add_verify_module uu____826
                         else ()
                     | VerifyUserList  ->
                         FStar_List.iter
                           (fun uu____835  ->
                              match uu____835 with
                              | (m,r) ->
                                  let uu____843 =
                                    let uu____844 =
                                      let uu____845 = string_of_lid lid true in
                                      FStar_String.lowercase uu____845 in
                                    (FStar_String.lowercase m) = uu____844 in
                                  if uu____843
                                  then FStar_ST.write r true
                                  else ()) verify_flags);
                    collect_decls decls)
             and collect_decls decls =
               FStar_List.iter
                 (fun x  ->
                    collect_decl x.FStar_Parser_AST.d;
                    FStar_List.iter collect_term x.FStar_Parser_AST.attrs)
                 decls
             and collect_decl uu___86_855 =
               match uu___86_855 with
               | FStar_Parser_AST.Include lid -> record_open false lid
               | FStar_Parser_AST.Open lid -> record_open false lid
               | FStar_Parser_AST.ModuleAbbrev (ident,lid) ->
                   ((let uu____861 = lowercase_join_longident lid true in
                     add_dep uu____861);
                    record_module_alias ident lid)
               | FStar_Parser_AST.TopLevelLet (uu____862,patterms) ->
                   FStar_List.iter
                     (fun uu____876  ->
                        match uu____876 with
                        | (pat,t) -> (collect_pattern pat; collect_term t))
                     patterms
               | FStar_Parser_AST.Main t -> collect_term t
               | FStar_Parser_AST.Assume (uu____883,t) -> collect_term t
               | FStar_Parser_AST.SubEffect
                   { FStar_Parser_AST.msource = uu____885;
                     FStar_Parser_AST.mdest = uu____886;
                     FStar_Parser_AST.lift_op =
                       FStar_Parser_AST.NonReifiableLift t;_}
                   -> collect_term t
               | FStar_Parser_AST.SubEffect
                   { FStar_Parser_AST.msource = uu____888;
                     FStar_Parser_AST.mdest = uu____889;
                     FStar_Parser_AST.lift_op = FStar_Parser_AST.LiftForFree
                       t;_}
                   -> collect_term t
               | FStar_Parser_AST.Val (uu____891,t) -> collect_term t
               | FStar_Parser_AST.SubEffect
                   { FStar_Parser_AST.msource = uu____893;
                     FStar_Parser_AST.mdest = uu____894;
                     FStar_Parser_AST.lift_op =
                       FStar_Parser_AST.ReifiableLift (t0,t1);_}
                   -> (collect_term t0; collect_term t1)
               | FStar_Parser_AST.Tycon (uu____898,ts) ->
                   let ts1 =
                     FStar_List.map
                       (fun uu____916  ->
                          match uu____916 with | (x,docnik) -> x) ts in
                   FStar_List.iter collect_tycon ts1
               | FStar_Parser_AST.Exception (uu____924,t) ->
                   FStar_Util.iter_opt t collect_term
               | FStar_Parser_AST.NewEffect ed -> collect_effect_decl ed
               | FStar_Parser_AST.Fsdoc uu____929 -> ()
               | FStar_Parser_AST.Pragma uu____930 -> ()
               | FStar_Parser_AST.TopLevelModule lid ->
                   (FStar_Util.incr num_of_toplevelmods;
                    (let uu____936 =
                       let uu____937 = FStar_ST.read num_of_toplevelmods in
                       uu____937 > (Prims.parse_int "1") in
                     if uu____936
                     then
                       let uu____940 =
                         let uu____941 =
                           let uu____942 = string_of_lid lid true in
                           FStar_Util.format1
                             "Automatic dependency analysis demands one module per file (module %s not supported)"
                             uu____942 in
                         FStar_Errors.Err uu____941 in
                       raise uu____940
                     else ()))
             and collect_tycon uu___87_944 =
               match uu___87_944 with
               | FStar_Parser_AST.TyconAbstract (uu____945,binders,k) ->
                   (collect_binders binders;
                    FStar_Util.iter_opt k collect_term)
               | FStar_Parser_AST.TyconAbbrev (uu____953,binders,k,t) ->
                   (collect_binders binders;
                    FStar_Util.iter_opt k collect_term;
                    collect_term t)
               | FStar_Parser_AST.TyconRecord
                   (uu____963,binders,k,identterms) ->
                   (collect_binders binders;
                    FStar_Util.iter_opt k collect_term;
                    FStar_List.iter
                      (fun uu____991  ->
                         match uu____991 with
                         | (uu____996,t,uu____998) -> collect_term t)
                      identterms)
               | FStar_Parser_AST.TyconVariant
                   (uu____1001,binders,k,identterms) ->
                   (collect_binders binders;
                    FStar_Util.iter_opt k collect_term;
                    FStar_List.iter
                      (fun uu____1036  ->
                         match uu____1036 with
                         | (uu____1043,t,uu____1045,uu____1046) ->
                             FStar_Util.iter_opt t collect_term) identterms)
             and collect_effect_decl uu___88_1051 =
               match uu___88_1051 with
               | FStar_Parser_AST.DefineEffect (uu____1052,binders,t,decls)
                   ->
                   (collect_binders binders;
                    collect_term t;
                    collect_decls decls)
               | FStar_Parser_AST.RedefineEffect (uu____1062,binders,t) ->
                   (collect_binders binders; collect_term t)
             and collect_binders binders =
               FStar_List.iter collect_binder binders
             and collect_binder uu___89_1070 =
               match uu___89_1070 with
               | {
                   FStar_Parser_AST.b = FStar_Parser_AST.Annotated
                     (uu____1071,t);
                   FStar_Parser_AST.brange = uu____1073;
                   FStar_Parser_AST.blevel = uu____1074;
                   FStar_Parser_AST.aqual = uu____1075;_} -> collect_term t
               | {
                   FStar_Parser_AST.b = FStar_Parser_AST.TAnnotated
                     (uu____1076,t);
                   FStar_Parser_AST.brange = uu____1078;
                   FStar_Parser_AST.blevel = uu____1079;
                   FStar_Parser_AST.aqual = uu____1080;_} -> collect_term t
               | { FStar_Parser_AST.b = FStar_Parser_AST.NoName t;
                   FStar_Parser_AST.brange = uu____1082;
                   FStar_Parser_AST.blevel = uu____1083;
                   FStar_Parser_AST.aqual = uu____1084;_} -> collect_term t
               | uu____1085 -> ()
             and collect_term t = collect_term' t.FStar_Parser_AST.tm
             and collect_constant uu___90_1087 =
               match uu___90_1087 with
               | FStar_Const.Const_int
                   (uu____1088,FStar_Pervasives_Native.Some
                    (signedness,width))
                   ->
                   let u =
                     match signedness with
                     | FStar_Const.Unsigned  -> "u"
                     | FStar_Const.Signed  -> "" in
                   let w =
                     match width with
                     | FStar_Const.Int8  -> "8"
                     | FStar_Const.Int16  -> "16"
                     | FStar_Const.Int32  -> "32"
                     | FStar_Const.Int64  -> "64" in
                   let uu____1098 = FStar_Util.format2 "fstar.%sint%s" u w in
                   add_dep uu____1098
               | uu____1099 -> ()
             and collect_term' uu___91_1100 =
               match uu___91_1100 with
               | FStar_Parser_AST.Wild  -> ()
               | FStar_Parser_AST.Const c -> collect_constant c
               | FStar_Parser_AST.Op (s,ts) ->
                   (if (FStar_Ident.text_of_id s) = "@"
                    then
                      (let uu____1107 =
                         let uu____1108 =
                           FStar_Ident.lid_of_path
                             (FStar_Ident.path_of_text
                                "FStar.List.Tot.Base.append")
                             FStar_Range.dummyRange in
                         FStar_Parser_AST.Name uu____1108 in
                       collect_term' uu____1107)
                    else ();
                    FStar_List.iter collect_term ts)
               | FStar_Parser_AST.Tvar uu____1110 -> ()
               | FStar_Parser_AST.Uvar uu____1111 -> ()
               | FStar_Parser_AST.Var lid -> record_lid lid
               | FStar_Parser_AST.Projector (lid,uu____1114) ->
                   record_lid lid
               | FStar_Parser_AST.Discrim lid -> record_lid lid
               | FStar_Parser_AST.Name lid -> record_lid lid
               | FStar_Parser_AST.Construct (lid,termimps) ->
                   (if (FStar_List.length termimps) = (Prims.parse_int "1")
                    then record_lid lid
                    else ();
                    FStar_List.iter
                      (fun uu____1138  ->
                         match uu____1138 with
                         | (t,uu____1142) -> collect_term t) termimps)
               | FStar_Parser_AST.Abs (pats,t) ->
                   (collect_patterns pats; collect_term t)
               | FStar_Parser_AST.App (t1,t2,uu____1150) ->
                   (collect_term t1; collect_term t2)
               | FStar_Parser_AST.Let (uu____1152,patterms,t) ->
                   (FStar_List.iter
                      (fun uu____1168  ->
                         match uu____1168 with
                         | (pat,t1) -> (collect_pattern pat; collect_term t1))
                      patterms;
                    collect_term t)
               | FStar_Parser_AST.LetOpen (lid,t) ->
                   (record_open true lid; collect_term t)
               | FStar_Parser_AST.Bind (uu____1177,t1,t2) ->
                   (collect_term t1; collect_term t2)
               | FStar_Parser_AST.Seq (t1,t2) ->
                   (collect_term t1; collect_term t2)
               | FStar_Parser_AST.If (t1,t2,t3) ->
                   (collect_term t1; collect_term t2; collect_term t3)
               | FStar_Parser_AST.Match (t,bs) ->
                   (collect_term t; collect_branches bs)
               | FStar_Parser_AST.TryWith (t,bs) ->
                   (collect_term t; collect_branches bs)
               | FStar_Parser_AST.Ascribed
                   (t1,t2,FStar_Pervasives_Native.None ) ->
                   (collect_term t1; collect_term t2)
               | FStar_Parser_AST.Ascribed
                   (t1,t2,FStar_Pervasives_Native.Some tac) ->
                   (collect_term t1; collect_term t2; collect_term tac)
               | FStar_Parser_AST.Record (t,idterms) ->
                   (FStar_Util.iter_opt t collect_term;
                    FStar_List.iter
                      (fun uu____1241  ->
                         match uu____1241 with
                         | (uu____1244,t1) -> collect_term t1) idterms)
               | FStar_Parser_AST.Project (t,uu____1247) -> collect_term t
               | FStar_Parser_AST.Product (binders,t) ->
                   (collect_binders binders; collect_term t)
               | FStar_Parser_AST.Sum (binders,t) ->
                   (collect_binders binders; collect_term t)
               | FStar_Parser_AST.QForall (binders,ts,t) ->
                   (collect_binders binders;
                    FStar_List.iter (FStar_List.iter collect_term) ts;
                    collect_term t)
               | FStar_Parser_AST.QExists (binders,ts,t) ->
                   (collect_binders binders;
                    FStar_List.iter (FStar_List.iter collect_term) ts;
                    collect_term t)
               | FStar_Parser_AST.Refine (binder,t) ->
                   (collect_binder binder; collect_term t)
               | FStar_Parser_AST.NamedTyp (uu____1285,t) -> collect_term t
               | FStar_Parser_AST.Paren t -> collect_term t
               | FStar_Parser_AST.Assign (uu____1288,t) -> collect_term t
               | FStar_Parser_AST.Requires (t,uu____1291) -> collect_term t
               | FStar_Parser_AST.Ensures (t,uu____1295) -> collect_term t
               | FStar_Parser_AST.Labeled (t,uu____1299,uu____1300) ->
                   collect_term t
               | FStar_Parser_AST.Attributes cattributes ->
                   FStar_List.iter collect_term cattributes
             and collect_patterns ps = FStar_List.iter collect_pattern ps
             and collect_pattern p = collect_pattern' p.FStar_Parser_AST.pat
             and collect_pattern' uu___92_1306 =
               match uu___92_1306 with
               | FStar_Parser_AST.PatWild  -> ()
               | FStar_Parser_AST.PatOp uu____1307 -> ()
               | FStar_Parser_AST.PatConst uu____1308 -> ()
               | FStar_Parser_AST.PatApp (p,ps) ->
                   (collect_pattern p; collect_patterns ps)
               | FStar_Parser_AST.PatVar uu____1314 -> ()
               | FStar_Parser_AST.PatName uu____1318 -> ()
               | FStar_Parser_AST.PatTvar uu____1319 -> ()
               | FStar_Parser_AST.PatList ps -> collect_patterns ps
               | FStar_Parser_AST.PatOr ps -> collect_patterns ps
               | FStar_Parser_AST.PatTuple (ps,uu____1328) ->
                   collect_patterns ps
               | FStar_Parser_AST.PatRecord lidpats ->
                   FStar_List.iter
                     (fun uu____1340  ->
                        match uu____1340 with
                        | (uu____1343,p) -> collect_pattern p) lidpats
               | FStar_Parser_AST.PatAscribed (p,t) ->
                   (collect_pattern p; collect_term t)
             and collect_branches bs = FStar_List.iter collect_branch bs
             and collect_branch uu____1358 =
               match uu____1358 with
               | (pat,t1,t2) ->
                   (collect_pattern pat;
                    FStar_Util.iter_opt t1 collect_term;
                    collect_term t2) in
             let uu____1370 = FStar_Parser_Driver.parse_file filename in
             match uu____1370 with
             | (ast,uu____1378) -> (collect_file ast; FStar_ST.read deps))
let print_graph graph =
  FStar_Util.print_endline
    "A DOT-format graph has been dumped in the current directory as dep.graph";
  FStar_Util.print_endline
    "With GraphViz installed, try: fdp -Tpng -odep.png dep.graph";
  FStar_Util.print_endline "Hint: cat dep.graph | grep -v _ | grep -v prims";
  (let uu____1409 =
     let uu____1410 =
       let uu____1411 =
         let uu____1412 =
           let uu____1414 =
             let uu____1416 = FStar_Util.smap_keys graph in
             FStar_List.unique uu____1416 in
           FStar_List.collect
             (fun k  ->
                let deps =
                  let uu____1427 =
                    let uu____1431 = FStar_Util.smap_try_find graph k in
                    FStar_Util.must uu____1431 in
                  FStar_Pervasives_Native.fst uu____1427 in
                let r s = FStar_Util.replace_char s '.' '_' in
                FStar_List.map
                  (fun dep1  ->
                     FStar_Util.format2 "  %s -> %s" (r k) (r dep1)) deps)
             uu____1414 in
         FStar_String.concat "\n" uu____1412 in
       Prims.strcat uu____1411 "\n}\n" in
     Prims.strcat "digraph {\n" uu____1410 in
   FStar_Util.write_file "dep.graph" uu____1409)
let collect:
  verify_mode ->
    Prims.string Prims.list ->
      ((Prims.string,Prims.string Prims.list) FStar_Pervasives_Native.tuple2
         Prims.list,Prims.string Prims.list,(Prims.string Prims.list,
                                              color)
                                              FStar_Pervasives_Native.tuple2
                                              FStar_Util.smap)
        FStar_Pervasives_Native.tuple3
  =
  fun verify_mode  ->
    fun filenames  ->
      let graph = FStar_Util.smap_create (Prims.parse_int "41") in
      let verify_flags =
        let uu____1484 = FStar_Options.verify_module () in
        FStar_List.map
          (fun f  ->
             let uu____1492 = FStar_Util.mk_ref false in (f, uu____1492))
          uu____1484 in
      let partial_discovery =
        let uu____1499 =
          (FStar_Options.verify_all ()) || (FStar_Options.extract_all ()) in
        Prims.op_Negation uu____1499 in
      let m = build_map filenames in
      let file_names_of_key k =
        let uu____1505 =
          let uu____1510 = FStar_Util.smap_try_find m k in
          FStar_Util.must uu____1510 in
        match uu____1505 with
        | (intf,impl) ->
            (match (intf, impl) with
             | (FStar_Pervasives_Native.None ,FStar_Pervasives_Native.None )
                 -> failwith "Impossible"
             | (FStar_Pervasives_Native.None ,FStar_Pervasives_Native.Some i)
                 -> i
             | (FStar_Pervasives_Native.Some i,FStar_Pervasives_Native.None )
                 -> i
             | (FStar_Pervasives_Native.Some i,uu____1541) when
                 partial_discovery -> i
             | (FStar_Pervasives_Native.Some i,FStar_Pervasives_Native.Some
                j) -> Prims.strcat i (Prims.strcat " && " j)) in
      let collect_one1 = collect_one verify_flags verify_mode in
      let rec discover_one is_user_provided_filename interface_only key =
        let uu____1567 =
          let uu____1568 = FStar_Util.smap_try_find graph key in
          uu____1568 = FStar_Pervasives_Native.None in
        if uu____1567
        then
          let uu____1583 =
            let uu____1588 = FStar_Util.smap_try_find m key in
            FStar_Util.must uu____1588 in
          match uu____1583 with
          | (intf,impl) ->
              let intf_deps =
                match intf with
                | FStar_Pervasives_Native.Some intf1 ->
                    collect_one1 is_user_provided_filename m intf1
                | FStar_Pervasives_Native.None  -> [] in
              let impl_deps =
                match (impl, intf) with
                | (FStar_Pervasives_Native.Some
                   impl1,FStar_Pervasives_Native.Some uu____1618) when
                    interface_only -> []
                | (FStar_Pervasives_Native.Some impl1,uu____1622) ->
                    collect_one1 is_user_provided_filename m impl1
                | (FStar_Pervasives_Native.None ,uu____1626) -> [] in
              let deps =
                FStar_List.unique (FStar_List.append impl_deps intf_deps) in
              (FStar_Util.smap_add graph key (deps, White);
               FStar_List.iter (discover_one false partial_discovery) deps)
        else () in
      let discover_command_line_argument f =
        let m1 = lowercase_module_name f in
        let interface_only =
          (is_interface f) &&
            (let uu____1645 =
               FStar_List.existsML
                 (fun f1  ->
                    (let uu____1650 = lowercase_module_name f1 in
                     uu____1650 = m1) && (is_implementation f1)) filenames in
             Prims.op_Negation uu____1645) in
        discover_one true interface_only m1 in
      FStar_List.iter discover_command_line_argument filenames;
      (let immediate_graph = FStar_Util.smap_copy graph in
       let topologically_sorted = FStar_Util.mk_ref [] in
       let rec discover cycle key =
         let uu____1675 =
           let uu____1679 = FStar_Util.smap_try_find graph key in
           FStar_Util.must uu____1679 in
         match uu____1675 with
         | (direct_deps,color) ->
             (match color with
              | Gray  ->
                  (FStar_Util.print1
                     "Warning: recursive dependency on module %s\n" key;
                   (let cycle1 =
                      FStar_All.pipe_right cycle
                        (FStar_List.map file_names_of_key) in
                    FStar_Util.print1
                      "The cycle contains a subset of the modules in:\n%s \n"
                      (FStar_String.concat "\n`used by` " cycle1);
                    print_graph immediate_graph;
                    FStar_Util.print_string "\n";
                    FStar_All.exit (Prims.parse_int "1")))
              | Black  -> direct_deps
              | White  ->
                  (FStar_Util.smap_add graph key (direct_deps, Gray);
                   (let all_deps =
                      let uu____1712 =
                        let uu____1714 =
                          FStar_List.map
                            (fun dep1  ->
                               let uu____1721 = discover (key :: cycle) dep1 in
                               dep1 :: uu____1721) direct_deps in
                        FStar_List.flatten uu____1714 in
                      FStar_List.unique uu____1712 in
                    FStar_Util.smap_add graph key (all_deps, Black);
                    (let uu____1729 =
                       let uu____1731 = FStar_ST.read topologically_sorted in
                       key :: uu____1731 in
                     FStar_ST.write topologically_sorted uu____1729);
                    all_deps))) in
       let discover1 = discover [] in
       let must_find k =
         let uu____1748 =
           let uu____1753 = FStar_Util.smap_try_find m k in
           FStar_Util.must uu____1753 in
         match uu____1748 with
         | (FStar_Pervasives_Native.Some intf,FStar_Pervasives_Native.Some
            impl) when
             (Prims.op_Negation partial_discovery) &&
               (let uu____1773 =
                  FStar_List.existsML
                    (fun f  ->
                       let uu____1777 = lowercase_module_name f in
                       uu____1777 = k) filenames in
                Prims.op_Negation uu____1773)
             -> [intf; impl]
         | (FStar_Pervasives_Native.Some intf,FStar_Pervasives_Native.Some
            impl) when
             FStar_List.existsML
               (fun f  ->
                  (is_implementation f) &&
                    (let uu____1785 = lowercase_module_name f in
                     uu____1785 = k)) filenames
             -> [intf; impl]
         | (FStar_Pervasives_Native.Some intf,uu____1787) -> [intf]
         | (FStar_Pervasives_Native.None ,FStar_Pervasives_Native.Some impl)
             -> [impl]
         | (FStar_Pervasives_Native.None ,FStar_Pervasives_Native.None ) ->
             [] in
       let must_find_r f =
         let uu____1801 = must_find f in FStar_List.rev uu____1801 in
       let by_target =
         let uu____1808 =
           let uu____1810 = FStar_Util.smap_keys graph in
           FStar_List.sortWith (fun x  -> fun y  -> FStar_String.compare x y)
             uu____1810 in
         FStar_List.collect
           (fun k  ->
              let as_list = must_find k in
              let is_interleaved =
                (FStar_List.length as_list) = (Prims.parse_int "2") in
              FStar_List.map
                (fun f  ->
                   let should_append_fsti =
                     (is_implementation f) && is_interleaved in
                   let k1 = lowercase_module_name f in
                   let suffix =
                     let uu____1847 =
                       let uu____1852 = FStar_Util.smap_try_find m k1 in
                       FStar_Util.must uu____1852 in
                     match uu____1847 with
                     | (FStar_Pervasives_Native.Some intf,uu____1868) when
                         should_append_fsti -> [intf]
                     | uu____1872 -> [] in
                   let deps =
                     let uu____1879 = discover1 k1 in
                     FStar_List.rev uu____1879 in
                   let deps_as_filenames =
                     let uu____1883 = FStar_List.collect must_find deps in
                     FStar_List.append uu____1883 suffix in
                   (f, deps_as_filenames)) as_list) uu____1808 in
       let topologically_sorted1 =
         let uu____1888 = FStar_ST.read topologically_sorted in
         FStar_List.collect must_find_r uu____1888 in
       FStar_List.iter
         (fun uu____1903  ->
            match uu____1903 with
            | (m1,r) ->
                let uu____1911 =
                  (let uu____1914 = FStar_ST.read r in
                   Prims.op_Negation uu____1914) &&
                    (let uu____1918 = FStar_Options.interactive () in
                     Prims.op_Negation uu____1918) in
                if uu____1911
                then
                  let maybe_fst =
                    let k = FStar_String.length m1 in
                    let uu____1923 =
                      (k > (Prims.parse_int "4")) &&
                        (let uu____1931 =
                           FStar_String.substring m1
                             (k - (Prims.parse_int "4"))
                             (Prims.parse_int "4") in
                         uu____1931 = ".fst") in
                    if uu____1923
                    then
                      let uu____1938 =
                        FStar_String.substring m1 (Prims.parse_int "0")
                          (k - (Prims.parse_int "4")) in
                      FStar_Util.format1 " Did you mean %s ?" uu____1938
                    else "" in
                  let uu____1946 =
                    let uu____1947 =
                      FStar_Util.format3
                        "You passed --verify_module %s but I found no file that contains [module %s] in the dependency graph.%s\n"
                        m1 m1 maybe_fst in
                    FStar_Errors.Err uu____1947 in
                  raise uu____1946
                else ()) verify_flags;
       (by_target, topologically_sorted1, immediate_graph))
let print_make:
  (Prims.string,Prims.string Prims.list) FStar_Pervasives_Native.tuple2
    Prims.list -> Prims.unit
  =
  fun deps  ->
    FStar_List.iter
      (fun uu____1977  ->
         match uu____1977 with
         | (f,deps1) ->
             let deps2 =
               FStar_List.map
                 (fun s  -> FStar_Util.replace_chars s ' ' "\\ ") deps1 in
             FStar_Util.print2 "%s: %s\n" f (FStar_String.concat " " deps2))
      deps
let print uu____2011 =
  match uu____2011 with
  | (make_deps,uu____2024,graph) ->
      let uu____2042 = FStar_Options.dep () in
      (match uu____2042 with
       | FStar_Pervasives_Native.Some "make" -> print_make make_deps
       | FStar_Pervasives_Native.Some "graph" -> print_graph graph
       | FStar_Pervasives_Native.Some uu____2044 ->
           raise (FStar_Errors.Err "unknown tool for --dep\n")
       | FStar_Pervasives_Native.None  -> ())