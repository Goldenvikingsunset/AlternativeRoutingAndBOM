tableextension 50101 "Requisition Line Ext" extends "Requisition Line"
{

    fields
    {
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
            begin
                if Type = Type::Item then
                    if "No." <> xRec."No." then
                        if Item.Get("No.") then begin
                            // Only process if it's a manufacturing item
                            if Item."Manufacturing Policy" = Item."Manufacturing Policy"::"Make-to-Stock" then begin
                                Validate("Routing No.", AlternativeProdMng.GetRoutingNo(
                                    "No.",
                                    "Variant Code",
                                    "Location Code",
                                    Quantity));

                                Validate("Production BOM No.", AlternativeProdMng.GetProductionBOMNo(
                                    "No.",
                                    "Variant Code",
                                    "Location Code",
                                    Quantity));
                            end;
                        end;
            end;
        }

        modify("Variant Code")
        {
            trigger OnAfterValidate()
            begin
                if (Type = Type::Item) and (CurrFieldNo = FieldNo("Variant Code")) then begin
                    Validate("Routing No.", AlternativeProdMng.GetRoutingNo(
                        "No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));

                    Validate("Production BOM No.", AlternativeProdMng.GetProductionBOMNo(
                        "No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));
                end;
            end;
        }

        modify("Location Code")
        {
            trigger OnAfterValidate()
            begin
                if (Type = Type::Item) and (CurrFieldNo = FieldNo("Location Code")) then begin
                    Validate("Routing No.", AlternativeProdMng.GetRoutingNo(
                        "No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));

                    Validate("Production BOM No.", AlternativeProdMng.GetProductionBOMNo(
                        "No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));
                end;
            end;
        }

        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                if (Type = Type::Item) and (CurrFieldNo = FieldNo(Quantity)) then begin
                    Validate("Routing No.", AlternativeProdMng.GetRoutingNo(
                        "No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));

                    Validate("Production BOM No.", AlternativeProdMng.GetProductionBOMNo(
                        "No.",
                        "Variant Code",
                        "Location Code",
                        Quantity));
                end;
            end;
        }
    }

    trigger OnAfterModify()
    var
        Item: Record Item;
    begin
        // Only process if it's an item and replenishment system is Prod. Order
        if (Type = Type::Item) and ("Replenishment System" = "Replenishment System"::"Prod. Order") then
            if Item.Get("No.") then
                if Item."Manufacturing Policy" = Item."Manufacturing Policy"::"Make-to-Stock" then
                    RefreshPlanningLine();
    end;

    local procedure RefreshPlanningLine()
    begin
        if ("Production BOM No." <> '') or ("Routing No." <> '') then begin
            CalcFields("Reserved Quantity");
            if "Reserved Quantity" = 0 then begin
                Validate("Production BOM No.");
                Validate("Routing No.");
            end;
        end;
    end;

    var
        AlternativeProdMng: Codeunit "Alternative Prod. Mng";

}