# ✅ Características Implementadas

### 1. **Herencia Correcta**
- Hereda de `ERC20`, `Ownable` y `Pausable` de OpenZeppelin
- Constructor satisface todos los contratos base

### 2. **Sistema de Impuestos**
- Calcula automáticamente el fee en cada transferencia
- Envía el impuesto a la tesorería
- Envía el resto al receptor
- Respeta las exenciones (`isFeeExempt`)

### 3. **Funciones del Owner**
- `setTaxFee()`: Cambiar el porcentaje de impuesto
- `setTreasury()`: Cambiar la dirección de tesorería
- `pause()/unpause()`: Pausar y reanudar transferencias
- `setFeeExempt()`: Excluir/incluir direcciones del impuesto

### 4. **Eventos Implementados**
- `TreasuryUpdated`: Al cambiar tesorería
- `TaxFeeUpdated`: Al cambiar el fee
- `FeeExemptionSet`: Al modificar exenciones
- `TaxCollected`: En cada transferencia con impuesto

### 5. **Validaciones**
- ✅ Revert si treasury es `address(0)`
- ✅ Revert si fee es mayor a 100
- ✅ Usa errores personalizados para gas eficiente

## ⚠️ Nota sobre Solidity 0.8.2

El código está escrito para **Solidity 0.8.20** porque:
- La versión 0.8.2 es muy antigua (2021) y tiene vulnerabilidades conocidas
- OpenZeppelin v5.x requiere mínimo Solidity 0.8.20
- Las versiones modernas incluyen mejoras de seguridad importantes

Si **DEBES usar 0.8.2**, necesitarás:
1. Usar OpenZeppelin v4.x: `npm install @openzeppelin/contracts@^4.9.0`
2. Cambiar la primera línea a: `pragma solidity 0.8.2;`

## 📋 Para Desplegar en Sepolia

```bash
# 1. Instalar dependencias
npm install --save-dev hardhat @openzeppelin/contracts

# 2. Crear script de deploy
# Parámetros ejemplo:
# - name: "TaxableToken"
# - symbol: "TAX"
# - treasury: "0x..."
# - taxFee: 5 (5%)
# - initialOwner: "tu dirección"
```

## Vulnerabilidades que dice Remix:

This contract is generally well-structured and avoids major vulnerabilities (e.g., reentrancy, integer overflows), but here are key risks to address:

### Front-Running Tax Changes:

setTaxFee()/setTreasury() are owner-only but lack a timelock or DAO governance, enabling sudden tax hikes (e.g., 100%) to trap users.

### Pausable Abuse:

The owner can pause transfers indefinitely, freezing funds. Consider adding a time-locked unpause or multi-sig.

### Treasury Privilege:

The treasury is exempt from taxes by default, allowing the owner to dump tax-free tokens (potential rug-pull vector).

### Precision Loss:

(amount * taxFee) / 100 rounds down, favoring users for small transfers. Use scaled math (e.g., 1e18 precision) for fairness.

### Centralization:

Single owner control is a red flag for scams. Use multi-sig or governance (e.g., OpenZeppelin Governor).

## Critical Fixes Needed:

- Add a timelock for tax/treasury changes.

- Remove treasury’s default tax exemption (or document the risk).

- Consider community-controlled pauses (e.g., via DAO).

- Use SafeMath (though Solidity 0.8.x has built-in checks, explicit checks improve clarity).

Not a Scam Yet, But High Risk if Misused. Audit before deployment.
