codeunit 50100 "Alternative Prod. Mng"
{
    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure OnAfterValidateReqLineNo(var Rec: Record "Requisition Line"; var xRec: Record "Requisition Line"; CurrFieldNo: Integer)
    begin
        if (Rec.Type = Rec.Type::Item) and (Rec."Replenishment System" = Rec."Replenishment System"::"Prod. Order") then begin
            Rec.Validate("Routing No.", GetRoutingNo(
                Rec."No.",
                Rec."Variant Code",
                Rec."Location Code",
                Rec.Quantity));

            Rec.Validate("Production BOM No.", GetProductionBOMNo(
                Rec."No.",
                Rec."Variant Code",
                Rec."Location Code",
                Rec.Quantity));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Requisition Line", 'OnAfterValidateEvent', 'Variant Code', false, false)]
    local procedure OnAfterValidateReqLineVariantCode(var Rec: Record "Requisition Line"; var xRec: Record "Requisition Line"; CurrFieldNo: Integer)
    begin
        if (Rec.Type = Rec.Type::Item) and
           (Rec."Replenishment System" = Rec."Replenishment System"::"Prod. Order") and
           (CurrFieldNo = Rec.FieldNo("Variant Code")) then begin
            Rec.Validate("Routing No.", GetRoutingNo(
                Rec."No.",
                Rec."Variant Code",
                Rec."Location Code",
                Rec.Quantity));

            Rec.Validate("Production BOM No.", GetProductionBOMNo(
                Rec."No.",
                Rec."Variant Code",
                Rec."Location Code",
                Rec.Quantity));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Prod. Order Lines", 'OnAfterProdOrderLineInsert', '', false, false)]
    local procedure OnAfterProdOrderLineInsert(var ProdOrderLine: Record "Prod. Order Line")
    begin
        UpdateAlternatives(ProdOrderLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", 'OnAfterValidateEvent', 'Variant Code', false, false)]
    local procedure OnAfterValidateVariantCode(var Rec: Record "Prod. Order Line"; var xRec: Record "Prod. Order Line"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = Rec.FieldNo("Variant Code") then
            UpdateAlternatives(Rec);
    end;

    local procedure UpdateAlternatives(var ProdOrderLine: Record "Prod. Order Line")
    var
        Item: Record Item;
        NewRoutingNo: Code[20];
        NewBOMNo: Code[20];
    begin
        if not Item.Get(ProdOrderLine."Item No.") then
            exit;

        NewRoutingNo := GetRoutingNo(
            ProdOrderLine."Item No.",
            ProdOrderLine."Variant Code",
            ProdOrderLine."Location Code",
            ProdOrderLine.Quantity);

        NewBOMNo := GetProductionBOMNo(
            ProdOrderLine."Item No.",
            ProdOrderLine."Variant Code",
            ProdOrderLine."Location Code",
            ProdOrderLine.Quantity);

        ProdOrderLine.Validate("Routing No.", NewRoutingNo);
        ProdOrderLine.Validate("Production BOM No.", NewBOMNo);
        ProdOrderLine.Modify(true);
    end;

    procedure GetRoutingNo(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; Quantity: Decimal): Code[20]
    var
        Item: Record Item;
        AlternativeRouting: Record "Alternative Routing";
    begin
        if not Item.Get(ItemNo) then
            exit(Item."Routing No.");

        AlternativeRouting.SetRange("Item No.", ItemNo);
        AlternativeRouting.SetFilter("Variant Code", '%1|%2', '', VariantCode);
        AlternativeRouting.SetFilter("Location Code", '%1|%2', '', LocationCode);
        AlternativeRouting.SetFilter("Min Order Size", '0|<=%1', Quantity);
        AlternativeRouting.SetFilter("Max Order Size", '0|>=%1', Quantity);

        if AlternativeRouting.FindFirst() then
            exit(AlternativeRouting."Routing No.")
        else
            exit(Item."Routing No.");
    end;

    procedure GetProductionBOMNo(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; Quantity: Decimal): Code[20]
    var
        Item: Record Item;
        AlternativeProdBOM: Record "Alternative Prod. BOM";
    begin
        if not Item.Get(ItemNo) then
            exit(Item."Production BOM No.");

        AlternativeProdBOM.SetRange("Item No.", ItemNo);
        AlternativeProdBOM.SetFilter("Variant Code", '%1|%2', '', VariantCode);
        AlternativeProdBOM.SetFilter("Location Code", '%1|%2', '', LocationCode);
        AlternativeProdBOM.SetFilter("Min Order Size", '0|<=%1', Quantity);
        AlternativeProdBOM.SetFilter("Max Order Size", '0|>=%1', Quantity);

        if AlternativeProdBOM.FindFirst() then
            exit(AlternativeProdBOM."Production BOM No.")
        else
            exit(Item."Production BOM No.");
    end;
}