#import "../../contracts/cameligo/oracle/main.mligo" "ORACLE"
#import "../../contracts/cameligo/oracle/types.mligo" "TYPES"
#import "./helpers/bootstrap.mligo" "BOOTSTRAP"
#import "./helpers/helper.mligo" "HELPER"
#import "./helpers/assert.mligo" "ASSERT"

let () = Test.log("___ TEST updateEvent STARTED ___")

let emptyMap : (nat, TYPES.eventType) map = (Map.empty : (nat, TYPES.eventType) map)

let oneEventMap : (nat, TYPES.eventType) map = Map.literal [
    (1n, BOOTSTRAP.primaryEvent)
    ]

let updatedEventMap : (nat, TYPES.eventType) map = Map.literal [
    (1n, BOOTSTRAP.secondaryEvent)
    ]

let (oracle_contract, oracle_taddress, elon, jeff, alice, _, _) = BOOTSTRAP.bootstrap
let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent)

let () = Test.log("-> Updating the first Event from Manager")
let () = HELPER.trscUpdateEvent (oracle_contract, elon, 1n, BOOTSTRAP.secondaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress updatedEventMap

let () = Test.log("-> Updating the first Event from Signer")
let () = HELPER.trscUpdateEvent (oracle_contract, jeff, 1n, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress oneEventMap

let () = Test.log("-> Updating the first Event from unauthorized address")
let () = HELPER.trscUpdateEvent (oracle_contract, alice, 1n, BOOTSTRAP.secondaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress oneEventMap

let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent)
let () = HELPER.trscAddEvent (oracle_contract, elon, BOOTSTRAP.primaryEvent)

let threeEventMap : (nat, TYPES.eventType) map = Map.literal [
    (1n, BOOTSTRAP.primaryEvent);
    (2n, BOOTSTRAP.primaryEvent);
    (3n, BOOTSTRAP.primaryEvent);
    ]
let () = ASSERT.assert_eventsMap oracle_taddress threeEventMap

let updatedThreeEventMap : (nat, TYPES.eventType) map = Map.literal [
    (1n, BOOTSTRAP.primaryEvent);
    (2n, BOOTSTRAP.primaryEvent);
    (3n, BOOTSTRAP.secondaryEvent);
    ]
let () = Test.log("-> Updating the third Event from Manager")
let () = HELPER.trscUpdateEvent (oracle_contract, elon, 3n, BOOTSTRAP.secondaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress updatedThreeEventMap

let () = Test.log("-> Updating the third Event from Signer")
let () = HELPER.trscUpdateEvent (oracle_contract, jeff, 3n, BOOTSTRAP.primaryEvent)
let () = ASSERT.assert_eventsMap oracle_taddress threeEventMap

let () = Test.log("___ TEST updateEvent ENDED ___")