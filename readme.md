# Alternative Production BOMs and Routings

## Overview
The Alternative Production BOMs and Routings functionality allows you to define different BOMs and routings for items based on:
- Variants (e.g., different colors or models)
- Locations (different production facilities)
- Order quantities (batch size variations)

This enables flexible manufacturing processes where production specifications can change based on these criteria.

## Setup

### Alternative Production BOM Setup
1. Navigate to Manufacturing → Setup → Alternative Production BOMs
2. Create a new record with:
   - Item No.: The manufactured item
   - Variant Code: Specific variant (optional)
   - Location Code: Specific production location (optional)
   - Min/Max Order Size: Order quantity range for this BOM
   - Production BOM No.: The alternative BOM to use

### Alternative Routing Setup
1. Navigate to Manufacturing → Setup → Alternative Routings
2. Create a new record with:
   - Item No.: The manufactured item
   - Variant Code: Specific variant (optional)
   - Location Code: Specific production location (optional)
   - Min/Max Order Size: Order quantity range for this routing
   - Routing No.: The alternative routing to use

### Access from Item Card
Alternative BOMs and Routings can be viewed and managed directly from the Item Card:
1. Two promoted actions in the Production category:
   - Alternative BOMs
   - Alternative Routings
2. Two FactBoxes showing current alternatives:
   - Alternative BOMs FactBox
   - Alternative Routings FactBox

## How It Works

### Selection Logic
The system selects the appropriate BOM and Routing based on:
1. Exact match on all criteria (Variant, Location, Order Size)
2. If no exact match:
   - Uses default BOM/Routing from Item Card
3. Order Size validation:
   - Min Order Size ≤ Order Quantity
   - Max Order Size ≥ Order Quantity (or 0 for no upper limit)

### Integration Points
Automatic BOM/Routing selection occurs in:
1. Production Orders:
   - When created manually
   - When refreshed
   - When variant code changes
2. Planning Worksheet:
   - During MRP calculations
   - When creating planned production orders
   - With SKU-based planning

## Example Scenarios

### Variant-Based Alternative
```
Item: Bicycle
Variant: BLUE
Location: MAIN
Min Order Size: 0
Max Order Size: 0
Production BOM No.: BOM-BLUE
```
When producing blue bicycles, the system automatically uses BOM-BLUE regardless of quantity.

### Location-Based Alternative
```
Item: Bicycle
Variant: *
Location: EAST
Min Order Size: 0
Max Order Size: 0
Routing No.: ROUTE-EAST
```
Production in the EAST location uses ROUTE-EAST routing regardless of variant or quantity.

### Quantity-Based Alternative
```
Item: Bicycle
Variant: *
Location: *
Min Order Size: 100
Max Order Size: 1000
Production BOM No.: BOM-BATCH
```
Orders between 100-1000 units use BOM-BATCH for more efficient large-scale production.

## Technical Implementation

### Key Components
1. Tables:
   - Alternative Prod. BOM
   - Alternative Routing

2. Pages:
   - Alternative Prod. BOM List
   - Alternative Routing List
   - FactBox pages on Item Card

3. Integration:
   - Production Order events
   - Planning Worksheet events
   - Variant code change handling

### Validation Rules
1. Item must exist and be Make-to-Stock
2. Variant must exist for the item (if specified)
3. Location must be valid manufacturing location
4. Min Order Size must be ≤ Max Order Size
5. Production BOM and Routing must be certified

## Best Practices

### Setup Guidelines
1. Use blank Variant/Location codes for general alternatives
2. Set Max Order Size = 0 for no upper limit
3. Create alternatives in order of specificity:
   - Most specific (all criteria) first
   - General alternatives last

### Performance Considerations
1. Keep number of alternatives manageable
2. Use order size ranges appropriately
3. Regular maintenance of obsolete records

## Troubleshooting

### Common Issues
1. Alternative not being selected:
   - Check variant code exists
   - Verify order quantity within range
   - Confirm location is valid
2. Wrong alternative selected:
   - Review selection criteria priority
   - Check for overlapping ranges

### Support
For additional support:
1. Review event log for selection process
2. Check user setup and permissions
3. Verify manufacturing setup is complete