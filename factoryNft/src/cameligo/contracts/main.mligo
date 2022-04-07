#import "storage.mligo" "Storage"
#import "parameter.mligo" "Parameter"
#import "tezos-ligo-fa2/lib/fa2/nft/NFT.mligo" "NFT_FA2"
//#import "views.mligo" "Views"
//#import "errors.mligo" "Errors"
//#import "conditions.mligo" "Conditions"

type storage = Storage.t
type parameter = Parameter.t
type return = operation list * storage

let generateCollection(param, store : Parameter.generate_collection_param * Storage.t) : return = 
    // create new collection
    let token_ids = param.token_ids in
    let ledger = (Big_map.empty : NFT_FA2.Ledger.t) in
    let myfunc(acc, elt : NFT_FA2.Ledger.t * nat) : NFT_FA2.Ledger.t = Big_map.add elt Tezos.sender acc in
    let new_ledger : NFT_FA2.Ledger.t = List.fold myfunc token_ids ledger in 
    let token_metadata = param.token_metas in
    let operators = (Big_map.empty : NFT_FA2.Operators.t) in
    
    let initial_storage : NFT_FA2.Storage.t = {
        ledger=new_ledger;
        operators=operators;
        token_ids=token_ids;
        token_metadata=token_metadata
    }  in 

    let initial_delegate : key_hash option = (None: key_hash option) in
    let initial_amount : tez = 1tez in
    let create_my_contract : (key_hash option * tez * NFT_FA2.Storage.t) -> (operation * address) =
      [%Michelson ( {| { 
            UNPAIR ;
            UNPAIR ;
            CREATE_CONTRACT {
#include "tezos-ligo-fa2/compiled/fa2/nft/NFT_mligo.tz"  
              } ;
            PAIR 
            } |}
              : (key_hash option * tez * NFT_FA2.Storage.t) -> (operation * address))]
    in

    let originate : operation * address = create_my_contract(initial_delegate, initial_amount, initial_storage) in
    // insert into collections
    let new_all_collections = Big_map.add originate.1 Tezos.sender store.all_collections in
    // insert into owned_collections
    let new_owned_collections = match Big_map.find_opt Tezos.sender store.owned_collections with
    | None -> Big_map.add Tezos.sender (Set.add originate.1 (Set.empty: address set)) store.owned_collections
    | Some addr_set -> Big_map.update Tezos.sender (Some(Set.add originate.1 addr_set)) store.owned_collections
    in
    ([originate.0], { store with all_collections=new_all_collections; owned_collections=new_owned_collections})


let main(ep, store : parameter * storage) : return =
    match ep with 
    | GenerateCollection(p) -> generateCollection(p, store)
    | Nothing -> (([] : operation list), store)
