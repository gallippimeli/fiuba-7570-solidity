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
        address payable owner;
    }

    uint m = 0;

    uint b = 0;

    Transaction[] lastTransactions;

    FutureTransaction[] public futures;

    uint[] futuresIndexToDelete;

    FutureTransaction[] senderFutureTransactions;

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
        futures.push(FutureTransaction(futurePrice, amount, date, false, msg.sender));
    }

    function consultarMisComprasFuturas() public returns (FutureTransaction[] memory) {
        return getFutureTransactionsBySender(msg.sender);
    }

    function consultarTodasLasComprasFuturas() public view returns (FutureTransaction[] memory) {
        return futures;
    }

    function ejecutarMisContratos() public {
        executeContractsBySender(msg.sender);
    }

    function ejecutarTodosLosContratos() public {
        executeAllContracts();
    }


    /**
     * Internal functions
     */
    function addTransaction(uint price) internal {
        lastTransactions.push(Transaction(now, price));
    }

    function getFutureTransactionsBySender(address sender) internal returns (FutureTransaction[] memory) {
        delete senderFutureTransactions;
        for (uint index = 0; index < futures.length; index++) {
            if (futures[index].date < now) {
                futures[index].isReady = true;
            }
            if (futures[index].owner == sender) {
                senderFutureTransactions.push(futures[index]);
            }
        }
        return senderFutureTransactions;
    }

    function executeContractsBySender(address payable sender) internal {
        delete futuresIndexToDelete;
        for (uint index = 0; index < futures.length; index++) {
            if (futures[index].owner == msg.sender) {
                if (futures[index].date < now) {
                    sender.transfer(futures[index].amount);
                    futuresIndexToDelete.push(index);
                }
            }
        }
        for (uint index = 0; index < futuresIndexToDelete.length; index++) {
            remove(futuresIndexToDelete[index]);
        }
    }

    function executeAllContracts() internal {
        delete futuresIndexToDelete;
        for (uint index = 0; index < futures.length; index++) {
            if (futures[index].date < now) {
                futures[index].owner.transfer(futures[index].amount);
                futuresIndexToDelete.push(index);
            }
        }
        for (uint index = 0; index < futuresIndexToDelete.length; index++) {
            remove(futuresIndexToDelete[index]);
        }
    }

    function remove(uint index)  internal {
        if (index >= futures.length) return;

        for (uint i = index; i<futures.length-1; i++){
            futures[i] = futures[i+1];
        }
        delete futures[futures.length-1];
        futures.length--;
    }
}