%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_block_timestamp
)

from contracts.ERC20_base import (
    ERC20_name,
    ERC20_symbol,
    ERC20_totalSupply,
    ERC20_decimals,
    ERC20_balanceOf,
    ERC20_allowance,
    ERC20_mint,

    ERC20_initializer,
    ERC20_approve,
    ERC20_increaseAllowance,
    ERC20_decreaseAllowance,
    ERC20_transfer,
    ERC20_transferFrom
)

#
# Storage vars
#

@storage_var
func UBI_accrued_since(account: felt) -> (accrued_since: felt):
end

@storage_var 
func UBI_accrued_per_second() -> (accrued_per_second: Uint256):
end


@constructor
func constructor{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        name: felt,
        symbol: felt,
        initial_supply: Uint256,
        recipient: felt,
        accruedPerSecond: Uint256):
    
    ERC20_initializer(name, symbol, initial_supply, recipient)
    UBI_accrued_per_second.write(accruedPerSecond)
    return ()
end

@view
func name{ syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() 
    -> (name: felt):

    let (name) = ERC20_name()
    return (name)
end

@view 
func symbol{ syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr }()
    -> (symbol: felt):

    let (symbol) = ERC20_symbol()
    return (symbol)
end

@view
func totalSupply{ syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}()
    -> (totalSupply: Uint256):
    let (totalSupply: Uint256) = ERC20_totalSupply()
    return (totalSupply)
end

@view
func decimals{ syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}()
    -> (decimals: felt):

    let(decimals) = ERC20_decimals()
    return (decimals)
end

@view
func balanceOf{ 
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(account: felt)
    -> (balance: Uint256):
    let (consolidatedBalance: Uint256) = ERC20_balanceOf(account)
    let (accruedPerSecond) = UBI_accrued_per_second.read()
    let (accruedSince) = UBI_accrued_since.read(account)
    let (timestamp) = get_block_timestamp()
    let (diff) = timestamp - accruedSince
    let (consolidatedBalance) = consolidatedBalance + (accruedSince * diff)
    return (consolidatedBalance)
end


@view
func allowance{ 
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(owner: felt, spender: felt)
    -> (remaining: Uint256):
    let (remaining: Uint256) = ERC20_allowance(owner, spender)
    return (remaining)
end

@view 
func accruedSince{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }(account: felt) -> (accruedSince: felt):
    let (accruedSince: felt) = UBI_accrued_since.read(account)
    return (accruedSince)
end

@view
func accruedPerSecond{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }() -> (accruedPerSecond: felt):
    let (accruedPerSecond: felt) = UBI_accrued_per_second.read()
    return (accruedPerSecond)
end

#
# External
#

@external
func faucet{ syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr }()
    -> (success: felt):
    let amount: Uint256 = Uint256(100*1000000000000000000, 0)
    let (caller) = get_caller_address()
    ERC20_mint(caller, amount)

    # equivalent to return true
    return (1)
end

@external
func transfer{ 
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr 
    }(recipient: felt, amount: Uint256) -> (success: felt):
    ERC20_transfer(recipient, amount)
    return (1)
end

@external
func transferFrom { 
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr 
    }(sender: felt, recipient: felt, amount: Uint256) -> (success: felt):
    ERC20_transferFrom(sender, recipient, amount)
    return (1)
end

@external
func approve{ 
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr 
    }(spender: felt, amount: Uint256) -> (success: felt):
    ERC20_approve(spender, amount)

    return (1)
end

@external
func increaseAllowance{ 
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr 
    }(spender: felt, addedValue: Uint256) -> (success: felt):
    ERC20_increaseAllowance(spender, addedValue)
    return (1)
end

@external
func decreaseAllowance{ 
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr 
    }(spender: felt, subtracted_value: Uint256) -> (success: felt):
    ERC20_decreaseAllowance(spender, subtracted_value)
    return (1)
end

@external
func startAccruing{
        syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
    }() -> (success: felt):
    
    let (caller) = get_caller_address()
    let (timestamp) = get_block_timestamp()
    UBI_accrued_since.write(caller, timestamp)
    return (1)
end 