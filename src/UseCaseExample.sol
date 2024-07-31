// SPDX-License-Identifier: BSD-3-Clause-Clear

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@sight-ai/contracts/Types.sol";
import "@sight-ai/contracts/Oracle.sol";
import "@sight-ai/contracts/ResponseResolver.sol";

enum State {
    Initial,
    Launching,
    Completed
}

// The FHE Coin Pusher Contract
contract UseCaseExample is Ownable2Step {

    // Use Sight Oracle's RequestBuilder and ResponseResolver to interact with Sight Oracle
    using RequestBuilder for RequestBuilder.Request;
    using ResponseResolver for CapsulatedValue;

    event TargetSet(uint64 indexed, uint64 indexed);
    event Deposit(address indexed, uint64 indexed);
    event GetTarget(bytes);
    event RevealTarget(uint64);
    event GameComplete(address indexed winner, uint64 finalSum);

    CapsulatedValue private _target;
    uint64 private _plaintext_target;
    uint64 private _sum;
    State private _state;
    address private _winner;
    Oracle_Demo27 public oracle;

    mapping(address => uint64) internal balances;
    mapping(bytes32 => address) requesters;
    mapping(bytes32 => bytes) requestExtraData;

    constructor(address oracle_) payable Ownable(msg.sender) {
        _state = State.Initial;
        oracle = Oracle_Demo27(payable(oracle_));
    }

    function setTarget(uint64 min, uint64 max) public payable onlyOwner {
        require(_state != State.Launching, "Game is not complete!");
        require(max > min, "require max > min");
        // clear up
        _plaintext_target = 0;

        // Initialize new FHE computation request of 3 steps.
        RequestBuilder.Request memory r = RequestBuilder.newRequest(
            msg.sender,
            3,
            address(this),
            this.setTarget_cb.selector,
            msg.data[4:]
        );

        uint64 range = max - min + 1;
        uint64 shards = (type(uint64).max / range + 1);

        // Step 1: generate random value
        op encryptedValueA = r.rand();

        // Step 2 - 3: limit the random value into range min - max
        op scaled_random_value = r.div(encryptedValueA, shards);
        r.add(scaled_random_value, min);

        // Call request.complete() to complete build process
        r.complete();

        // Keep some context in local storage
        requestExtraData[r.id] = msg.data[4:];
        requesters[r.id] = msg.sender;

        // Send the request via Sight FHE Oracle
        oracle.send(r);
    }

    // only Oracle can call this
    function setTarget_cb(bytes32 requestId, CapsulatedValue[] memory EVs) public onlyOracle {
        // Load context from local storage
        bytes memory extraData = requestExtraData[requestId];
        (uint64 min, uint64 max) = abi.decode(extraData, (uint64, uint64));

        // Decode value from Oracle callback
        CapsulatedValue memory final_result = EVs[EVs.length - 1];

        // Keep this encrypted target value
        _target = final_result;

        // initialize status
        _winner = address(0);
        _sum = 0;
        _state = State.Launching;

        emit TargetSet(min, max);
    }

    function deposit(uint64 amount) public {
        require(_state == State.Launching, "Game not launching or Game already Completed.");

        // Initialize new FHE computation request of 3 steps.
        RequestBuilder.Request memory r = RequestBuilder.newRequest(
            msg.sender,
            3,
            address(this),
            this.deposit_cb.selector,
            abi.encode(msg.sender, amount)
        );
        uint64 balance_after = balances[msg.sender] + amount;

        // Step 1: load local stored encrypted target into request processing context
        op e_target = r.getEuint64(_target.asEuint64());

        // Step 2: compare balance and encrypted_target
        op e_greater = r.ge(balance_after, e_target);

        // Step 3: decrypt the comparison result, it is safe to reveal
        r.decryptEbool(e_greater);

        // complete the request
        r.complete();

        requestExtraData[r.id] = abi.encode(msg.sender, amount);
        // send request to Sight FHE Oracle
        oracle.send(r);
    }


    // only Oracle can call this
    function deposit_cb(bytes32 requestId, CapsulatedValue[] memory EVs) public onlyOracle {
        bytes memory extraData = requestExtraData[requestId];
        (address requester, uint64 amount) = abi.decode(extraData, (address, uint64));
        // CapsulatedValue 0: the encrypted target
        // CapsulatedValue 1: the encrypted compare result
        // CapsulatedValue 2: the decrypted compare result, as used here
        CapsulatedValue memory final_result = EVs[EVs.length - 1];
        balances[requester] += amount;
        _sum += amount;
        emit Deposit(requester, amount);

        // Check winning condition
        bool isWinner = final_result.asBool();
        if (isWinner) {
            _winner = requester;
            _state = State.Completed;
            emit GameComplete(_winner, _sum);
        }
    }


    // Reveal the target
    function revealTarget() public {
        require(_state == State.Completed, "Game is not complete!");

        // Initialize new FHE computation request of 2 steps.
        RequestBuilder.Request memory r = RequestBuilder.newRequest(
            msg.sender,
            2,
            address(this),
            this.revealTarget_cb.selector,
            ""
        );

        // Step 1: load encrypted target into processing context
        op e_target = r.getEuint64(_target.asEuint64());

        // Step 2: decrypt the target
        r.decryptEuint64(e_target);

        r.complete();

        oracle.send(r);
    }

    // only Oracle can call this
    function revealTarget_cb(bytes32 requestId, CapsulatedValue[] memory EVs) public onlyOracle {
        CapsulatedValue memory final_result = EVs[EVs.length - 1];

        // unwrap the plaintext value
        uint64 target = final_result.asUint64();

        _plaintext_target = target;
        emit RevealTarget(target);
    }

    modifier onlyOracle() {
        require(msg.sender == address(oracle), "Only Oracle Can Do This");
        _;
    }

    function isComplete() public view returns (bool) {
        return _state == State.Completed;
    }

    function winner() public view returns (address) {
        return _winner;
    }

    function sum() public view returns (uint64) {
        return _sum;
    }

    function myBalance() public view returns (uint64) {
        return balances[msg.sender];
    }

    function getTarget() public view returns (uint64) {
        return _plaintext_target;
    }

    function gameState() public view returns (State) {
        return _state;
    }

    fallback() external payable {}
    receive() external payable {}
}
