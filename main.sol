// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TaxableToken
 * @dev ERC20 token con sistema de impuestos en transferencias
 */
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
    
    /**
     * @dev Constructor del contrato
     * @param name Nombre del token
     * @param symbol Símbolo del token
     * @param _treasury Dirección de la tesorería
     * @param _taxFee Porcentaje de impuesto (0-100)
     * @param initialOwner Dirección del propietario inicial
     */
    constructor(
        string memory name,
        string memory symbol,
        address _treasury,
        uint256 _taxFee,
        address initialOwner
    ) ERC20(name, symbol) Ownable(initialOwner) {
        if (_treasury == address(0)) {
            revert InvalidTreasuryAddress();
        }
        if (_taxFee > 100) {
            revert InvalidTaxFee();
        }
        
        treasury = _treasury;
        taxFee = _taxFee;
        
        // El owner y la tesorería están exentos por defecto
        isFeeExempt[initialOwner] = true;
        isFeeExempt[_treasury] = true;
        isFeeExempt[address(this)] = true;
        
        // Mint inicial al owner (ejemplo: 1,000,000 tokens)
        _mint(initialOwner, 1_000_000 * 10**decimals());
    }
    
    /**
     * @dev Actualiza la dirección de la tesorería
     * @param _newTreasury Nueva dirección de tesorería
     */
    function setTreasury(address _newTreasury) external onlyOwner {
        if (_newTreasury == address(0)) {
            revert InvalidTreasuryAddress();
        }
        
        address oldTreasury = treasury;
        treasury = _newTreasury;
        
        // La nueva tesorería queda exenta automáticamente
        isFeeExempt[_newTreasury] = true;
        
        emit TreasuryUpdated(oldTreasury, _newTreasury);
    }
    
    /**
     * @dev Actualiza el porcentaje de impuesto
     * @param _newTaxFee Nuevo porcentaje (0-100)
     */
    function setTaxFee(uint256 _newTaxFee) external onlyOwner {
        if (_newTaxFee > 100) {
            revert InvalidTaxFee();
        }
        
        uint256 oldFee = taxFee;
        taxFee = _newTaxFee;
        
        emit TaxFeeUpdated(oldFee, _newTaxFee);
    }
    
    /**
     * @dev Establece la exención de impuestos para una dirección
     * @param account Dirección a modificar
     * @param exempt true para exentar, false para aplicar impuestos
     */
    function setFeeExempt(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
        emit FeeExemptionSet(account, exempt);
    }
    
    /**
     * @dev Pausa todas las transferencias
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Reanuda las transferencias
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Override de _update para implementar el sistema de impuestos
     */
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
        
        // Calcular el impuesto
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
    
    /**
     * @dev Función de utilidad para verificar si una dirección está exenta
     */
    function isAddressExempt(address account) external view returns (bool) {
        return isFeeExempt[account];
    }
    
    /**
     * @dev Calcula el impuesto y monto neto para una transferencia
     */
    function calculateTax(uint256 amount) external view returns (uint256 taxAmount, uint256 netAmount) {
        taxAmount = (amount * taxFee) / 100;
        netAmount = amount - taxAmount;
        return (taxAmount, netAmount);
    }
}