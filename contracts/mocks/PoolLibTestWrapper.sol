// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "../libraries/PoolLib.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IPool.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title PoolLibTestWrapper
 * @dev Wrapper around PoolLib to facilitate testing.
 */
contract PoolLibTestWrapper is ERC20("PoolLibTest", "PLT") {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _activeLoans;

    event LifeCycleStateTransition(IPoolLifeCycleState state);
    event FirstLossDeposited(
        address indexed caller,
        address indexed supplier,
        uint256 amount
    );
    event FirstLossWithdrawn(
        address indexed caller,
        address indexed receiver,
        uint256 amount
    );
    event Deposit(
        address indexed caller,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );

    function executeFirstLossDeposit(
        address liquidityAsset,
        address spender,
        uint256 amount,
        address firstLossVault,
        IPoolLifeCycleState currentState,
        uint256 minFirstLossRequired
    ) external {
        PoolLib.executeFirstLossDeposit(
            liquidityAsset,
            spender,
            amount,
            firstLossVault,
            currentState,
            minFirstLossRequired
        );
    }

    function executeFirstLossWithdraw(
        uint256 amount,
        address withdrawReceiver,
        address firstLossVault
    ) external returns (uint256) {
        return
            PoolLib.executeFirstLossWithdraw(
                amount,
                withdrawReceiver,
                firstLossVault
            );
    }

    function calculateAssetsToShares(
        uint256 assets,
        uint256 sharesTotalSupply,
        uint256 nav
    ) external pure returns (uint256) {
        return PoolLib.calculateAssetsToShares(assets, sharesTotalSupply, nav);
    }

    function calculateSharesToAssets(
        uint256 shares,
        uint256 sharesTotalSupply,
        uint256 nav
    ) external pure returns (uint256 assets) {
        return PoolLib.calculateSharesToAssets(shares, sharesTotalSupply, nav);
    }

    function calculateTotalAssets(
        address asset,
        address vault,
        uint256 outstandingLoanPrincipals
    ) external view returns (uint256) {
        return
            PoolLib.calculateTotalAssets(
                asset,
                vault,
                outstandingLoanPrincipals
            );
    }

    function calculateTotalAvailableAssets(
        address asset,
        address vault,
        uint256 outstandingLoanPrincipals,
        uint256 withdrawableAssets
    ) external view returns (uint256) {
        return
            PoolLib.calculateTotalAvailableAssets(
                asset,
                vault,
                outstandingLoanPrincipals,
                withdrawableAssets
            );
    }

    function calculateTotalAvailableShares(
        address vault,
        uint256 redeemableShares
    ) external view returns (uint256) {
        return PoolLib.calculateTotalAvailableShares(vault, redeemableShares);
    }

    function calculateMaxDeposit(
        IPoolLifeCycleState poolLifeCycleState,
        uint256 poolMaxCapacity,
        uint256 totalAvailableAssets
    ) external pure returns (uint256) {
        return
            PoolLib.calculateMaxDeposit(
                poolLifeCycleState,
                poolMaxCapacity,
                totalAvailableAssets
            );
    }

    function setMockActiveLoans(address[] memory loans) public {
        // Clear out prior entries
        for (uint256 i = 0; i < _activeLoans.length(); i++) {
            _activeLoans.remove(_activeLoans.at(i));
        }
        // Add new loans
        for (uint256 i = 0; i < loans.length; i++) {
            _activeLoans.add(loans[i]);
        }
    }

    function calculateExpectedInterestFromMocks()
        public
        view
        returns (uint256 expectedInterest)
    {
        return PoolLib.calculateExpectedInterest(_activeLoans);
    }

    function executeDeposit(
        address asset,
        address vault,
        address sharesReceiver,
        uint256 assets,
        uint256 shares,
        uint256 maxDeposit
    ) external returns (uint256) {
        return
            PoolLib.executeDeposit(
                asset,
                vault,
                sharesReceiver,
                assets,
                shares,
                maxDeposit,
                _mint
            );
    }

    function isPoolLoan(
        address loan,
        address serviceConfiguration,
        address pool
    ) public view returns (bool) {
        return PoolLib.isPoolLoan(loan, serviceConfiguration, pool);
    }

    function calculateCurrentWithdrawPeriod(
        uint256 currentTimestamp,
        uint256 activatedAt,
        uint256 withdrawalWindowDuration
    ) public pure returns (uint256) {
        return
            PoolLib.calculateCurrentWithdrawPeriod(
                currentTimestamp,
                activatedAt,
                withdrawalWindowDuration
            );
    }

    function caclulateWithdrawState(
        IPoolWithdrawState memory state,
        uint256 currentPeriod,
        uint256 requestPeriod,
        uint256 requestedShares
    ) public pure returns (IPoolWithdrawState memory) {
        return
            PoolLib.caclulateWithdrawState(
                state,
                currentPeriod,
                requestPeriod,
                requestedShares
            );
    }

    function calculateRequestFee(uint256 shares, uint256 requestFeeBps)
        external
        pure
        returns (uint256)
    {
        return PoolLib.calculateRequestFee(shares, requestFeeBps);
    }

    function calculateMaxRedeemRequest(
        IPoolWithdrawState memory state,
        uint256 shareBalance,
        uint256 requestFeeBps
    ) public pure returns (uint256) {
        return
            PoolLib.calculateMaxRedeemRequest(
                state,
                shareBalance,
                requestFeeBps
            );
    }
}
