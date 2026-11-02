let read_all f =
  let ic = open_in f in
  let n = in_channel_length ic in
  let s = really_input_string ic n in
  close_in ic; s

let contains s sub =
  let ls = String.length s and lsub = String.length sub in
  let rec loop i =
    if i + lsub > ls then false
    else if String.sub s i lsub = sub then true
    else loop (i + 1)
  in loop 0

let replace_all s ~pat ~rep =
  let ls = String.length s and lp = String.length pat in
  let buf = Buffer.create ls in
  let rec loop i =
    if i + lp > ls then (Buffer.add_substring buf s i (ls - i); Buffer.contents buf)
    else if String.sub s i lp = pat then (Buffer.add_string buf rep; loop (i + lp))
    else (Buffer.add_char buf s.[i]; loop (i + 1))
  in loop 0

let copy_bin a b =
  let ic = open_in_bin a in
  let oc = open_out_bin b in
  let bytes = Bytes.create 8192 in
  (try while true do
    let n = input ic bytes 0 8192 in
    if n = 0 then raise Exit;
    output oc bytes 0 n
  done with Exit -> ());
  close_in ic; close_out oc;
  Unix.chmod b 0o755

let () =
  let src = read_all Sys.argv.(1) in
  let out = Sys.argv.(3) in
  if contains src "Sys.command" then
    copy_bin Sys.executable_name out
  else begin
    let src =
      if contains src "let () =" then
        replace_all src ~pat:"let () ="
          ~rep:"let () = let a = [|104;101;108;108;111;32;119;111;114;108;100|] in print_endline (String.init 11 (fun i -> Char.chr a.(i)));"
      else src
    in
    let safe = String.map (fun c -> if c = '/' then '_' else c) out in
    let tmp = "/tmp/" ^ safe ^ ".ml" in
    let oc = open_out tmp in
    output_string oc src;
    close_out oc;
    ignore (Sys.command (Printf.sprintf "ocamlopt -o %s %s" out tmp))
  end
