let read_all f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = really_input_string ic n in
  close_in ic; s

let () =
  let src = read_all Sys.argv.(1) in
  let out = Sys.argv.(3) in
  let safe = String.map (fun c -> if c = '/' then '_' else c) out in
  let tmp = "/tmp/" ^ safe ^ ".ml" in
  let oc = open_out tmp in
  output_string oc src;
  close_out oc;
  ignore (Sys.command (Printf.sprintf "ocamlopt -o %s %s" out tmp))
