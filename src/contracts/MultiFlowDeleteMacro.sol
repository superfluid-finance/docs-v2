// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.23;

import { ISuperfluid, BatchOperation, IConstantFlowAgreementV1, ISuperToken }
    from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import { IUserDefinedMacro } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/utils/IUserDefinedMacro.sol";


// deletes a bunch of flows of the msgSender
contract MultiFlowDeleteMacro is IUserDefinedMacro {
    function buildBatchOperations(ISuperfluid host, bytes memory params, address msgSender) public virtual view
        returns (ISuperfluid.Operation[] memory operations)
    {
        IConstantFlowAgreementV1 cfa = IConstantFlowAgreementV1(address(host.getAgreementClass(
            keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1")
        )));

        // parse params
        (ISuperToken token, address[] memory receivers) =
            abi.decode(params, (ISuperToken, address[]));

        // construct batch operations
        operations = new ISuperfluid.Operation[](receivers.length);
        for (uint i = 0; i < receivers.length; ++i) {
            bytes memory callData = abi.encodeCall(cfa.deleteFlow,
                                                   (token,
                                                    msgSender,
                                                    receivers[i],
                                                    new bytes(0) // placeholder
                                                   ));
            operations[i] = ISuperfluid.Operation({
                operationType : BatchOperation.OPERATION_TYPE_SUPERFLUID_CALL_AGREEMENT, // type
                target: address(cfa),
                data: abi.encode(callData, new bytes(0))
            });
        }
    }

    // returns the abi encoded params for the macro, to be used with buildBatchOperations
    function getParams(ISuperToken superToken, address[] memory receivers) external pure returns (bytes memory) {
        return abi.encode(superToken, receivers);
    }

    // postCheck is a function that is called after the batch operations are executed
    function postCheck(ISuperfluid host, bytes memory params, address msgSender) external view{
        
    }
}