// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract TaxableToken is ERC20, Ownable, Pausable {
    
    // Variables de estado
    address public treasury;
    uint256 public taxFee; // Fee en porcentaje (0-100)
    
    // Mapping para direcciones exentas de impuestos
    mapping(address => bool) public isFeeExempt;
    
    // Eventos
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event TaxFeeUpdated(uint256 oldFee, uint256 newFee);
    event FeeExemptionSet(address indexed account, bool isExempt);
    event TaxCollected(address indexed from, address indexed to, uint256 taxAmount, uint256 netAmount);
    
    // Errores personalizados
    error InvalidTreasuryAddress();
    error InvalidTaxFee();
    error TransferFailed();
    
    constructor(
        address initialOwner,
        string memory name,
        string memory symbol,
        address _treasury,
        uint256 _taxFee
    ) ERC20(name, symbol) Ownable(initialOwner) {
        if (_treasury == address(0)) {
            revert InvalidTreasuryAddress();
        }
        if (_taxFee > 100) {
            revert InvalidTaxFee();
        }
        
        treasury = _treasury;
        taxFee = _taxFee;
        
        // Exentos por defecto
        isFeeExempt[initialOwner] = true;
        isFeeExempt[_treasury] = true;
        isFeeExempt[address(this)] = true;
        
        // Tokens iniciales al owner 1000000
        _mint(initialOwner, 1_000_000 * 10**decimals());
    }
    
    function setTreasury(address _newTreasury) external onlyOwner {
        if (_newTreasury == address(0)) {
            revert InvalidTreasuryAddress();
        }
        
        address oldTreasury = treasury;
        treasury = _newTreasury;
        isFeeExempt[_newTreasury] = true;
        
        emit TreasuryUpdated(oldTreasury, _newTreasury);
    }
    
    function setTaxFee(uint256 _newTaxFee) external onlyOwner {
        if (_newTaxFee > 100) {
            revert InvalidTaxFee();
        }
        
        uint256 oldFee = taxFee;
        taxFee = _newTaxFee;
        
        emit TaxFeeUpdated(oldFee, _newTaxFee);
    }
    
    function setFeeExempt(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
        emit FeeExemptionSet(account, exempt);
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override whenNotPaused {
        // Si es mint o burn, o si alguna parte está exenta, no aplicar impuesto
        if (from == address(0) || to == address(0) || 
            isFeeExempt[from] || isFeeExempt[to] || 
            taxFee == 0) {
            super._update(from, to, amount);
            return;
        }
        
        uint256 taxAmount = (amount * taxFee) / 100;
        uint256 netAmount = amount - taxAmount;
        
        // Transferir el impuesto a la tesorería
        if (taxAmount > 0) {
            super._update(from, treasury, taxAmount);
        }
        
        // Transferir el monto neto al receptor
        super._update(from, to, netAmount);
        
        emit TaxCollected(from, to, taxAmount, netAmount);
    }
    
    function isAddressExempt(address account) external view returns (bool) {
        return isFeeExempt[account];
    }
    
    function calculateTax(uint256 amount) external view returns (uint256 taxAmount, uint256 netAmount) {
        taxAmount = (amount * taxFee) / 100;
        netAmount = amount - taxAmount;
        return (taxAmount, netAmount);
    }
}