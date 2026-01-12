/// A simple contracts that demonstrates how to send messages with cedra_message.
module core_messages::sender {
    use cedra_message::cedra_message;
    use cedra_framework::coin;

    struct State has key {
        emitter_cap: cedra_message::emitter::EmitterCapability,
    }

    entry fun init_module(core_messages: &signer) {
        // Register ourselves as a cedra_message emitter. This gives back an
        // `EmitterCapability` which will be required to send messages through
        // cedra_message.
        let emitter_cap = cedra_message::register_emitter();
        move_to(core_messages, State { emitter_cap });
    }

    #[test_only]
    /// Initialise module for testing.
    public fun init_module_test() {
        use cedra_framework::account;
        // recover the signer for the module's account
        let signer_cap = account::create_test_signer_cap(@core_messages);
        let signer = account::create_signer_with_capability(&signer_cap);
        // then call the initialiser
        init_module(&signer)
    }

    public entry fun send_message(user: &signer, payload: vector<u8>) acquires State {
        // Retrieve emitter capability from the state
        let emitter_cap = &mut borrow_global_mut<State>(@core_messages).emitter_cap;

        // Set nonce to 0 (this field is not interesting for regular messages,
        // only batch VAAs)
        let nonce: u64 = 0;

        let message_fee = cedra_message::state::get_message_fee();
        let fee_coins = coin::withdraw(user, message_fee);

        let _sequence = cedra_message::publish_message(
            emitter_cap,
            nonce,
            payload,
            fee_coins
        );
    }
}

#[test_only]
module core_messages::sender_test {
    use cedra_message::cedra_message;
    use core_messages::sender;
    use cedra_framework::account;
    use cedra_framework::cedra_coin::{Self, CedraCoin};
    use cedra_framework::coin;
    use cedra_framework::signer;
    use cedra_framework::timestamp;

    #[test(cedra_framework = @cedra_framework, user = @0x111)]
    public fun test_send_message(cedra_framework: &signer, user: &signer) {
        let message_fee = 100;
        timestamp::set_time_has_started_for_testing(cedra_framework);
        cedra_message::init_test(
            22,
            1,
            x"0000000000000000000000000000000000000000000000000000000000000004",
            x"beFA429d57cD18b7F8A4d91A2da9AB4AF05d0FBe",
            message_fee
        );
        sender::init_module_test();

        let (burn_cap, mint_cap) = cedra_coin::initialize_for_test(cedra_framework);

        // create user account and airdrop coins
        account::create_account_for_test(signer::address_of(user));
        coin::register<CedraCoin>(user);
        coin::deposit(signer::address_of(user), coin::mint(message_fee, &mint_cap));

        sender::send_message(user, b"hi mom");

        coin::destroy_mint_cap(mint_cap);
        coin::destroy_burn_cap(burn_cap);
    }
}
