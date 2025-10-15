# ✅ Desarrollo

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
- `TreasuryUpdated`: Cambiar tesorería
- `TaxFeeUpdated`: Cambiar el fee
- `FeeExemptionSet`: Mdificar exenciones
- `TaxCollected`: Cada transferencia con impuesto

### 5. **Validaciones**
- ✅ Revert si treasury es `address(0)`
- ✅ Revert si fee es mayor a 100
- ✅ Usa errores personalizados para gas eficiente

## ⚠️ Nota sobre Solidity 0.8.2

El código está escrito para **Solidity 0.8.20** porque:
- La versión 0.8.2 es muy antigua (2021) y tiene vulnerabilidades conocidas
- OpenZeppelin v5.x requiere mínimo Solidity 0.8.20
- Las versiones modernas incluyen mejoras de seguridad importantes
- Contenido completo de la tarea en el PDF.
- Link del contrato Verificado: [Contrato Verificado](https://repo.sourcify.dev/11155111/0xebfb195e1Cbde134c8758AC30CA7b663a5b7777E)
