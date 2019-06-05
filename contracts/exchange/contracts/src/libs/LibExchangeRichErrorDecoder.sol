/*

  Copyright 2019 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.9;

import "@0x/contracts-exchange-libs/contracts/src/LibOrder.sol";
import "@0x/contracts-utils/contracts/src/LibBytes.sol";
import "../MixinAssetProxyDispatcher.sol";
import "../MixinExchangeRichErrors.sol";
import "../MixinSignatureValidator.sol";
import "../MixinTransactions.sol";


contract LibExchangeRichErrorDecoder {
    // bytes4(keccak256("SignatureError(uint8,bytes32,address,bytes)"))
    bytes4 internal constant SIGNATURE_ERROR_SELECTOR =
        0x7e5a2318;

    // bytes4(keccak256("SignatureValidatorError(bytes32,address,bytes,bytes)"))
    bytes4 internal constant SIGNATURE_VALIDATOR_ERROR_SELECTOR =
        0x169fad8c;

    // bytes4(keccak256("SignatureWalletError(bytes32,address,bytes,bytes)"))
    bytes4 internal constant SIGNATURE_WALLET_ERROR_SELECTOR =
        0x1b8388f7;

    // bytes4(keccak256("SignatureOrderValidatorError(bytes32,address,bytes,bytes)"))
    bytes4 internal constant SIGNATURE_ORDER_VALIDATOR_ERROR_SELECTOR =
        0xfabf4577;

    // bytes4(keccak256("SignatureWalletOrderValidatorError(bytes32,address,bytes,bytes)"))
    bytes4 internal constant SIGNATURE_WALLET_ORDER_VALIDATOR_ERROR_SELECTOR =
        0xa85f3360;

    // bytes4(keccak256("OrderStatusError(bytes32,uint8)"))
    bytes4 internal constant ORDER_STATUS_ERROR_SELECTOR =
        0xfdb6ca8d;

    // bytes4(keccak256("InvalidSenderError(bytes32,address)"))
    bytes4 internal constant INVALID_SENDER_ERROR_SELECTOR =
        0x95b59997;

    // bytes4(keccak256("InvalidMakerError(bytes32,address)"))
    bytes4 internal constant INVALID_MAKER_ERROR_SELECTOR =
        0x26bf55d9;

    // bytes4(keccak256("FillError(uint8,bytes32)"))
    bytes4 internal constant FILL_ERROR_SELECTOR =
        0xe94a7ed0;

    // bytes4(keccak256("InvalidTakerError(bytes32,address)"))
    bytes4 internal constant INVALID_TAKER_ERROR_SELECTOR =
        0xfdb328be;

    // bytes4(keccak256("OrderEpochError(address,address,uint256)"))
    bytes4 internal constant ORDER_EPOCH_ERROR_SELECTOR =
        0x4ad31275;

    // bytes4(keccak256("AssetProxyExistsError(address)"))
    bytes4 internal constant ASSET_PROXY_EXISTS_ERROR_SELECTOR =
        0xcc8b3b53;

    // bytes4(keccak256("AssetProxyDispatchError(uint8,bytes32,bytes)"))
    bytes4 internal constant ASSET_PROXY_DISPATCH_ERROR_SELECTOR =
        0x488219a6;

    // bytes4(keccak256("AssetProxyTransferError(bytes32,bytes,bytes)"))
    bytes4 internal constant ASSET_PROXY_TRANSFER_ERROR_SELECTOR =
        0x4678472b;

    // bytes4(keccak256("NegativeSpreadError(bytes32,bytes32)"))
    bytes4 internal constant NEGATIVE_SPREAD_ERROR_SELECTOR =
        0xb6555d6f;

    // bytes4(keccak256("TransactionError(uint8,bytes32)"))
    bytes4 internal constant TRANSACTION_ERROR_SELECTOR =
        0xf5985184;

    // bytes4(keccak256("TransactionSignatureError(bytes32,address,bytes)"))
    bytes4 internal constant TRANSACTION_SIGNATURE_ERROR_SELECTOR =
        0xbfd56ef6;

    // bytes4(keccak256("TransactionExecutionError(bytes32,bytes)"))
    bytes4 internal constant TRANSACTION_EXECUTION_ERROR_SELECTOR =
        0x20d11f61;

    // bytes4(keccak256("IncompleteFillError(bytes32)"))
    bytes4 internal constant INCOMPLETE_FILL_ERROR_SELECTOR =
        0x152aa60e;

    /// @dev Decompose an ABI-encoded SignatureError.
    /// @param encoded ABI-encoded revert error.
    /// @return errorCode The error code.
    /// @return signerAddress The expected signer of the hash.
    /// @return signature The full signature.
    function decodeSignatureError(bytes memory encoded)
        public
        pure
        returns (
            MixinExchangeRichErrors.SignatureErrorCodes errorCode,
            bytes32 hash,
            address signerAddress,
            bytes memory signature
        )
    {
        _assertSelectorBytes(encoded, SIGNATURE_ERROR_SELECTOR);
        errorCode = MixinExchangeRichErrors.SignatureErrorCodes(_readErrorParameterAsUint256(encoded, 0));
        hash = _readErrorParameterAsBytes32(encoded, 1);
        signerAddress = _readErrorParameterAsAddress(encoded, 2);
        signature = _readErrorParameterAsBytes(encoded, 3);
    }

    /// @dev Decompose an ABI-encoded SignatureValidatorError.
    /// @param encoded ABI-encoded revert error.
    /// @return signerAddress The expected signer of the hash.
    /// @return signature The full signature bytes.
    /// @return errorData The revert data thrown by the validator contract.
    function decodeSignatureValidatorError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 hash,
            address signerAddress,
            bytes memory signature,
            bytes memory errorData
        )
    {
        _assertSelectorBytes(encoded, SIGNATURE_VALIDATOR_ERROR_SELECTOR);
        hash = _readErrorParameterAsBytes32(encoded, 0);
        signerAddress = _readErrorParameterAsAddress(encoded, 1);
        signature = _readErrorParameterAsBytes(encoded, 2);
        errorData = _readErrorParameterAsBytes(encoded, 3);
    }

    /// @dev Decompose an ABI-encoded SignatureWalletError.
    /// @param encoded ABI-encoded revert error.
    /// @return errorCode The error code.
    /// @return signerAddress The expected signer of the hash.
    /// @return signature The full signature bytes.
    /// @return errorData The revert data thrown by the validator contract.
    function decodeSignatureWalletError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 hash,
            address signerAddress,
            bytes memory signature,
            bytes memory errorData
        )
    {
        _assertSelectorBytes(encoded, SIGNATURE_WALLET_ERROR_SELECTOR);
        hash = _readErrorParameterAsBytes32(encoded, 0);
        signerAddress = _readErrorParameterAsAddress(encoded, 1);
        signature = _readErrorParameterAsBytes(encoded, 2);
        errorData = _readErrorParameterAsBytes(encoded, 3);
    }

    /// @dev Decompose an ABI-encoded SignatureOrderValidatorError.
    /// @param encoded ABI-encoded revert error.
    /// @return errorCode The error code.
    /// @return signerAddress The expected signer of the hash.
    /// @return signature The full signature bytes.
    /// @return errorData The revert data thrown by the validator contract.
    function decodeSignatureOrderValidatorError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 hash,
            address signerAddress,
            bytes memory signature,
            bytes memory errorData
        )
    {
        _assertSelectorBytes(encoded, SIGNATURE_ORDER_VALIDATOR_ERROR_SELECTOR);
        hash = _readErrorParameterAsBytes32(encoded, 0);
        signerAddress = _readErrorParameterAsAddress(encoded, 1);
        signature = _readErrorParameterAsBytes(encoded, 2);
        errorData = _readErrorParameterAsBytes(encoded, 3);
    }

    /// @dev Decompose an ABI-encoded SignatureWalletOrderValidatorError.
    /// @param encoded ABI-encoded revert error.
    /// @return errorCode The error code.
    /// @return signerAddress The expected signer of the hash.
    /// @return signature The full signature bytes.
    /// @return errorData The revert data thrown by the validator contract.
    function decodeSignatureWalletOrderValidatorError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 hash,
            address signerAddress,
            bytes memory signature,
            bytes memory errorData
        )
    {
        _assertSelectorBytes(encoded, SIGNATURE_WALLET_ORDER_VALIDATOR_ERROR_SELECTOR);
        hash = _readErrorParameterAsBytes32(encoded, 0);
        signerAddress = _readErrorParameterAsAddress(encoded, 1);
        signature = _readErrorParameterAsBytes(encoded, 2);
        errorData = _readErrorParameterAsBytes(encoded, 3);
    }

    /// @dev Decompose an ABI-encoded OrderStatusError.
    /// @param encoded ABI-encoded revert error.
    /// @return orderHash The order hash.
    /// @return orderStatus The order status.
    function decodeOrderStatusError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 orderHash,
            LibOrder.OrderStatus orderStatus
        )
    {
        _assertSelectorBytes(encoded, ORDER_STATUS_ERROR_SELECTOR);
        orderHash = _readErrorParameterAsBytes32(encoded, 0);
        orderStatus = LibOrder.OrderStatus(_readErrorParameterAsUint256(encoded, 1));
    }

    /// @dev Decompose an ABI-encoded InvalidSenderError.
    /// @param encoded ABI-encoded revert error.
    /// @return orderHash The order hash.
    /// @return senderAddress The sender.
    function decodeInvalidSenderError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 orderHash,
            address senderAddress
        )
    {
        _assertSelectorBytes(encoded, INVALID_SENDER_ERROR_SELECTOR);
        orderHash = _readErrorParameterAsBytes32(encoded, 0);
        senderAddress = _readErrorParameterAsAddress(encoded, 1);
    }

    /// @dev Decompose an ABI-encoded InvalidMakerError.
    /// @param encoded ABI-encoded revert error.
    /// @return orderHash The order hash.
    /// @return makerAddress The maker of the order.
    function decodeInvalidMakerError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 orderHash,
            address makerAddress
        )
    {
        _assertSelectorBytes(encoded, INVALID_MAKER_ERROR_SELECTOR);
        orderHash = _readErrorParameterAsBytes32(encoded, 0);
        makerAddress = _readErrorParameterAsAddress(encoded, 1);
    }

    /// @dev Decompose an ABI-encoded InvalidTaker.
    /// @param encoded ABI-encoded revert error.
    /// @return orderHash The order hash.
    /// @return takerAddress The taker of the order.
    function decodeInvalidTakerError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 orderHash,
            address takerAddress
        )
    {
        _assertSelectorBytes(encoded, INVALID_TAKER_ERROR_SELECTOR);
        orderHash = _readErrorParameterAsBytes32(encoded, 0);
        takerAddress = _readErrorParameterAsAddress(encoded, 1);
    }

    /// @dev Decompose an ABI-encoded FillError.
    /// @param encoded ABI-encoded revert error.
    /// @return errorCode The error code.
    /// @return orderHash The order hash.
    function decodeFillError(bytes memory encoded)
        public
        pure
        returns (
            MixinExchangeRichErrors.FillErrorCodes errorCode,
            bytes32 orderHash
        )
    {
        _assertSelectorBytes(encoded, FILL_ERROR_SELECTOR);
        errorCode = MixinExchangeRichErrors.FillErrorCodes(_readErrorParameterAsUint256(encoded, 0));
        orderHash = _readErrorParameterAsBytes32(encoded, 1);
    }

    /// @dev Decompose an ABI-encoded OrderEpochError.
    /// @param encoded ABI-encoded revert error.
    /// @return makerAddress The order maker.
    /// @return orderSenderAddress The order sender.
    /// @return currentEpoch The current epoch for the maker.
    function decodeOrderEpochError(bytes memory encoded)
        public
        pure
        returns (
            address makerAddress,
            address orderSenderAddress,
            uint256 currentEpoch
        )
    {
        _assertSelectorBytes(encoded, ORDER_EPOCH_ERROR_SELECTOR);
        makerAddress = _readErrorParameterAsAddress(encoded, 0);
        orderSenderAddress = _readErrorParameterAsAddress(encoded, 1);
        currentEpoch = _readErrorParameterAsUint256(encoded, 2);
    }

    /// @dev Decompose an ABI-encoded AssetProxyExistsError.
    /// @param encoded ABI-encoded revert error.
    /// @return proxyAddress The address of the asset proxy.
    function decodeAssetProxyExistsError(bytes memory encoded)
        public
        pure
        returns (address assetProxyAddress)
    {
        _assertSelectorBytes(encoded, ASSET_PROXY_EXISTS_ERROR_SELECTOR);
        assetProxyAddress = _readErrorParameterAsAddress(encoded, 0);
    }

    /// @dev Decompose an ABI-encoded AssetProxyDispatchError.
    /// @param encoded ABI-encoded revert error.
    /// @return errorCode The error code.
    /// @return orderHash Hash of the order being dispatched.
    /// @return assetData Asset data of the order being dispatched.
    function decodeAssetProxyDispatchError(bytes memory encoded)
        public
        pure
        returns (
            MixinExchangeRichErrors.AssetProxyDispatchErrorCodes errorCode,
            bytes32 orderHash,
            bytes memory assetData
        )
    {
        _assertSelectorBytes(encoded, ASSET_PROXY_DISPATCH_ERROR_SELECTOR);
        errorCode = MixinExchangeRichErrors.AssetProxyDispatchErrorCodes(_readErrorParameterAsUint256(encoded, 0));
        orderHash = _readErrorParameterAsBytes32(encoded, 1);
        assetData = _readErrorParameterAsBytes(encoded, 2);
    }

    /// @dev Decompose an ABI-encoded AssetProxyTransferError.
    /// @param encoded ABI-encoded revert error.
    /// @return orderHash Hash of the order being dispatched.
    /// @return assetData Asset data of the order being dispatched.
    /// @return errorData ABI-encoded revert data from the asset proxy.
    function decodeAssetProxyTransferError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 orderHash,
            bytes memory assetData,
            bytes memory errorData
        )
    {
        _assertSelectorBytes(encoded, ASSET_PROXY_TRANSFER_ERROR_SELECTOR);
        orderHash = _readErrorParameterAsBytes32(encoded, 0);
        assetData = _readErrorParameterAsBytes(encoded, 1);
        errorData = _readErrorParameterAsBytes(encoded, 2);
    }

    /// @dev Decompose an ABI-encoded NegativeSpreadError.
    /// @param encoded ABI-encoded revert error.
    /// @return leftOrderHash Hash of the left order being matched.
    /// @return rightOrderHash Hash of the right order being matched.
    function decodeNegativeSpreadError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 leftOrderHash,
            bytes32 rightOrderHash
        )
    {
        _assertSelectorBytes(encoded, NEGATIVE_SPREAD_ERROR_SELECTOR);
        leftOrderHash = _readErrorParameterAsBytes32(encoded, 0);
        rightOrderHash = _readErrorParameterAsBytes32(encoded, 1);
    }

    /// @dev Decompose an ABI-encoded TransactionError.
    /// @param encoded ABI-encoded revert error.
    /// @return errorCode The error code.
    /// @return transactionHash Hash of the transaction.
    function decodeTransactionError(bytes memory encoded)
        public
        pure
        returns (
            MixinExchangeRichErrors.TransactionErrorCodes errorCode,
            bytes32 transactionHash
        )
    {
        _assertSelectorBytes(encoded, TRANSACTION_ERROR_SELECTOR);
        errorCode = MixinExchangeRichErrors.TransactionErrorCodes(_readErrorParameterAsUint256(encoded, 0));
        transactionHash = _readErrorParameterAsBytes32(encoded, 1);
    }

    /// @dev Decompose an ABI-encoded TransactionSignatureError.
    /// @param encoded ABI-encoded revert error.
    /// @return transactionHash Hash of the transaction.
    /// @return signerAddress Signer of the transaction.
    /// @return signature Full signature for the transaction.
    function decodeTransactionSignatureError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 transactionHash,
            address signerAddress,
            bytes memory signature
        )
    {
        _assertSelectorBytes(encoded, TRANSACTION_SIGNATURE_ERROR_SELECTOR);
        transactionHash = _readErrorParameterAsBytes32(encoded, 0);
        signerAddress = _readErrorParameterAsAddress(encoded, 1);
        signature = _readErrorParameterAsBytes(encoded, 2);
    }

    /// @dev Decompose an ABI-encoded TransactionExecutionError.
    /// @param encoded ABI-encoded revert error.
    /// @return transactionHash Hash of the transaction.
    /// @return errorData Error thrown by exeucteTransaction().
    function decodeTransactionExecutionError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 transactionHash,
            bytes memory errorData
        )
    {
        _assertSelectorBytes(encoded, TRANSACTION_EXECUTION_ERROR_SELECTOR);
        transactionHash = _readErrorParameterAsBytes32(encoded, 0);
        errorData = _readErrorParameterAsBytes(encoded, 1);
    }

    /// @dev Decompose an ABI-encoded IncompleteFillError.
    /// @param encoded ABI-encoded revert error.
    /// @return orderHash Hash of the order being filled.
    function decodeIncompleteFillError(bytes memory encoded)
        public
        pure
        returns (
            bytes32 orderHash
        )
    {
        _assertSelectorBytes(encoded, INCOMPLETE_FILL_ERROR_SELECTOR);
        orderHash = _readErrorParameterAsBytes32(encoded, 0);
    }

    /// @dev Revert if the leading 4 bytes of `encoded` is not `selector`.
    function _assertSelectorBytes(bytes memory encoded, bytes4 selector)
        private
        pure
    {
        bytes4 actualSelector = LibBytes.readBytes4(encoded, 0);
        require(
            actualSelector == selector,
            "BAD_SELECTOR"
        );
    }

    /// @dev Read a parameter at index `index` as a uint256.
    function _readErrorParameterAsUint256(bytes memory encoded, uint256 index)
        private
        pure
        returns (uint256 value)
    {
        uint256 parameterOffset = 4 + index * 32;
        return LibBytes.readUint256(encoded, parameterOffset);
    }

    /// @dev Read a parameter at index `index` as a bytes32.
    function _readErrorParameterAsBytes32(bytes memory encoded, uint256 index)
        private
        pure
        returns (bytes32 value)
    {
        uint256 parameterOffset = 4 + index * 32;
        return LibBytes.readBytes32(encoded, parameterOffset);
    }

    /// @dev Read a parameter at index `index` as an address.
    function _readErrorParameterAsAddress(bytes memory encoded, uint256 index)
        private
        pure
        returns (address value)
    {
        uint256 parameterOffset = 4 + index * 32;
        return address(uint160(LibBytes.readUint256(encoded, parameterOffset)));
    }

    /// @dev Read a parameter at index `index` as a bytes.
    function _readErrorParameterAsBytes(bytes memory encoded, uint256 index)
        private
        pure
        returns (bytes memory value)
    {
        uint256 dataOffset = 4 + _readErrorParameterAsUint256(encoded, index);
        return LibBytes.readBytesWithLength(encoded, dataOffset);
    }

    /// @dev Read a parameter at index `index` as a string.
    function _readErrorParameterAsString(bytes memory encoded, uint256 index)
        private
        pure
        returns (string memory value)
    {
        return string(_readErrorParameterAsBytes(encoded, index));
    }
}
