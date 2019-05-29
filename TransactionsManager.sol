pragma solidity ^0.5.8;

pragma experimental ABIEncoderV2;

import './SafeMath.sol';

contract TransactionsManager {
    using SafeMath for uint;

    struct Transaction {
        uint dateCreated;
        uint price;
    }

    struct FutureTransaction {
        uint price;
        uint amount;
        uint date;
        bool isReady;
    }

    uint m = 0;

    uint b = 0;

    Transaction[] lastTransactions;

    address payable[] futureSenders;

    mapping (address => FutureTransaction[]) futureTransactions;

    FutureTransaction[] allFutureTransactions;

    FutureTransaction[] notReadyTransactions;

    constructor() public {
        m = 0;
        b = 0;
    }

    /**
     * Required functions for the practice
     */
    function ejecutarRegresion() public {
        uint transactionsAmount = lastTransactions.length;
        uint lastTransactionsAmount = 4;
        require(
            transactionsAmount >= lastTransactionsAmount,
            "Restricción: debes tener un mínimo de 4 transacciones"
        );
        uint t = 0;
        uint y = 0;
        uint ty = 0;
        uint tt = 0;
        for (uint index = transactionsAmount - lastTransactionsAmount; index < transactionsAmount; index++) {
            t = t.add(lastTransactions[index].dateCreated);
            y = y.add(lastTransactions[index].price);
            ty = ty.add(lastTransactions[index].dateCreated.mul(lastTransactions[index].price));
            tt = tt.add(lastTransactions[index].dateCreated.mul(lastTransactions[index].dateCreated));
        }
        m = (lastTransactionsAmount.mul(ty).sub((t.mul(y)))).div((lastTransactionsAmount.mul(tt)).sub((t.mul(t))));
        b = y.sub((b.mul(t))).div(lastTransactionsAmount);
    }

    function calcularValorFuturo(uint date) public view returns (uint) {
        return b.add(m.mul(date));
    }

    function comprarMonedaFutura(uint date, uint amount) public payable {
        require(
            date > now,
            "Restricción: la fecha debe ser mayor a la actual"
        );
        require(
            date < now.add(90 days),
            "Restricción: No podrás comprar a más de 90 días"
            );
        uint futurePrice = calcularValorFuturo(date);
        if (futureTransactions[msg.sender].length == 0) {
            futureSenders.push(msg.sender);
        }
        futureTransactions[msg.sender].push(FutureTransaction(futurePrice, amount, date, false));
    }

    function consultarMisComprasFuturas() public view returns (FutureTransaction[] memory) {
        return getFutureTransactionsBySender(msg.sender);
    }

    function consultarTodasLasComprasFuturas() public returns (FutureTransaction[] memory) {
        delete allFutureTransactions;
        for (uint index = 0; index < futureSenders.length; index++) {
            address sender = futureSenders[index];
            FutureTransaction[] memory futureTransactionsBySender = getFutureTransactionsBySender(sender);
            for (uint otherIndex = 0; otherIndex < futureTransactionsBySender.length; otherIndex++) {
                allFutureTransactions.push(futureTransactionsBySender[otherIndex]);
            }
        }
        return allFutureTransactions;
    }

    function ejecutarMisContratos() public {
        executeContractsBySender(msg.sender);
    }

    function ejecutarTodosLosContratos() public {
        for (uint index = 0; index < futureSenders.length; index++) {
            executeContractsBySender(futureSenders[index]);
        }
    }


    /**
     * Internal functions
     */
    function addTransaction(uint price) internal {
        lastTransactions.push(Transaction(now, price));
    }

    function getFutureTransactionsBySender(address sender) internal view returns (FutureTransaction[] memory) {
        FutureTransaction[] memory senderFutureTransactions = futureTransactions[sender];
        for (uint index = 0; index < senderFutureTransactions.length; index++) {
            if (senderFutureTransactions[index].date > now) {
                senderFutureTransactions[index].isReady = true;
            }
        }
        return senderFutureTransactions;
    }

    function executeContractsBySender(address payable sender) internal {
        delete notReadyTransactions;
        FutureTransaction[] memory futureTransactionsBySender = getFutureTransactionsBySender(sender);
        for (uint index = 0; index < futureTransactionsBySender.length; index++) {
            FutureTransaction memory futureTransaction = futureTransactionsBySender[index];
            if (futureTransaction.isReady) {
                sender.transfer(futureTransaction.amount);
            } else {
                notReadyTransactions.push(futureTransaction);
            }
        }
        futureTransactions[sender] = notReadyTransactions;
    }

}