tableextension 50100 "Prod. Order Line Ext" extends "Prod. Order Line"
{

    fields
    {
        modify("Item No.")
        {
            trigger OnAfterValidate()
            begin
                if "Item No." <> xRec."Item No." then begin
                    // Replace default assignments
                    Validate("Routing No.", AlternativeProdMng.GetRoutingNo(
                        "Item No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));

                    Validate("Production BOM No.", AlternativeProdMng.GetProductionBOMNo(
                        "Item No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));
                end;
            end;
        }

        modify("Variant Code")
        {
            trigger OnafterValidate()
            begin
                if CurrFieldNo = FieldNo("Variant Code") then begin
                    // Same logic as the original C/AL code
                    Validate("Routing No.", AlternativeProdMng.GetRoutingNo(
                        "Item No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));

                    Validate("Production BOM No.", AlternativeProdMng.GetProductionBOMNo(
                        "Item No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));
                end;
            end;
        }
    }

    var
        AlternativeProdMng: Codeunit "Alternative Prod. Mng";
}