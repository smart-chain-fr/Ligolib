#import "tezos-ligo-fa2/test/helpers/list.mligo" "List_helper"
#import "./helpers/dao.mligo" "DAO_helper"
#import "./helpers/token.mligo" "Token_helper"
#import "./helpers/time.mligo" "Time_helper"
#import "./helpers/suite.mligo" "Suite_helper"
#import "./helpers/log.mligo" "Log"
#import "./helpers/assert.mligo" "Assert"
#import "./bootstrap/bootstrap.mligo" "Bootstrap"
#import "../src/main.mligo" "DAO"

let () = Log.describe("[Cancel] test suite")

(* Boostrapping of the test environment, *)
let init_tok_amount = 33n
let bootstrap () = Bootstrap.boot(init_tok_amount)
let empty_nat_option = (None: nat option)

(* Successful cancel of current proposal *)
let test_success_current_proposal =
    let (tok, dao, sender_) = bootstrap() in

    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in
    let () = DAO_helper.cancel_success(empty_nat_option, dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in
    let () = DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Canceled) in
    Token_helper.assert_balance_amount(
        tok.taddr,
        sender_,
        abs(init_tok_amount - dao_storage.config.deposit_amount)
    )

(* Succesful cancel of accepted proposal, before timelock is unlocked *)
let test_success_accepted_proposal =
    let (tok, dao, sender_) = bootstrap() in

    (* empty operation list *)
    let () = Suite_helper.make_proposal_success(tok, dao, Some(
        (0xef67ec8260f062258375ab178c485146d467843d2a69b8eae7181441397f4021,
        OperationList)
    )) in

    let () = DAO_helper.cancel_success(Some(1n), dao.contr) in
    let dao_storage = Test.get_storage dao.taddr in
    DAO_helper.assert_proposal_state(dao_storage.outcomes, 1n, Canceled)

(* Failing cancel because there is nothing to cancel *)
let test_failure_nothing_to_cancel =
    let (tok, dao, sender_) = bootstrap() in

    let r = DAO_helper.cancel(empty_nat_option, dao.contr) in
    Assert.string_failure r DAO.Errors.nothing_to_cancel

(* Failing cancel because the outcome was not found *)
let test_failure_outcome_not_found =
    let (tok, dao, sender_) = bootstrap() in

    let r = DAO_helper.cancel(Some(23n), dao.contr) in
    Assert.string_failure r DAO.Errors.outcome_not_found

(* Failing cancel proposal because not creator *)
let test_failure_not_creator =
    let (tok, dao, sender_) = bootstrap() in
    let () = DAO_helper.propose_success(DAO_helper.dummy_proposal, dao.contr) in

    let sender_ = List_helper.nth_exn 2 tok.owners in
    let () = Test.set_source sender_ in
    let r = DAO_helper.cancel(empty_nat_option, dao.contr) in
    let () = Assert.string_failure r DAO.Errors.not_creator in

    (* restore back bootstrap sender *)
    Test.set_source sender_

(* Failing cancel proposal because timelock is unlocked *)
let test_failure_timelock_unlocked =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    (* empty operation list *)
    let () = Suite_helper.make_proposal_success(tok, dao, Some(
        (0xef67ec8260f062258375ab178c485146d467843d2a69b8eae7181441397f4021,
        OperationList)
    )) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in

    let r = DAO_helper.cancel(Some(1n), dao.contr) in
    Assert.string_failure r DAO.Errors.timelock_unlocked

(* Failing cancel proposal because it was already executed *)
let test_failure_already_executed =
    let (tok, dao, sender_) = bootstrap() in
    let dao_storage = Test.get_storage dao.taddr in

    (* empty operation list *)
    let () = Suite_helper.make_proposal_success(tok, dao, Some(
        (0xef67ec8260f062258375ab178c485146d467843d2a69b8eae7181441397f4021,
        OperationList)
    )) in
    let () = Time_helper.advance(dao_storage.config.timelock_delay) in
    let () = DAO_helper.execute_success(1n, 0x0502000000060320053d036d, dao.contr) in

    let r = DAO_helper.cancel(Some(1n), dao.contr) in
    Assert.string_failure r DAO.Errors.already_executed

