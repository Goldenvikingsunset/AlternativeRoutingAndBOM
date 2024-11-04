table 50100 "Alternative Prod. BOM"
{
    Caption = 'Alternative Production BOM';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Item.Get("Item No.") then begin
                    if Item."Manufacturing Policy" <> Item."Manufacturing Policy"::"Make-to-Stock" then
                        Error(ItemMustBeMTSErr, "Item No.");
                end else
                    Error(ItemNotFoundErr, "Item No.");
            end;
        }

        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            var
                ItemVariant: Record "Item Variant";
            begin
                if "Variant Code" <> '' then
                    if not ItemVariant.Get("Item No.", "Variant Code") then
                        Error(VariantNotFoundErr, "Variant Code", "Item No.");
            end;
        }

        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if "Location Code" <> '' then
                    if not Location.Get("Location Code") then
                        Error(LocationNotFoundErr, "Location Code");
            end;
        }

        field(4; "Min Order Size"; Decimal)
        {
            Caption = 'Minimum Order Size';
            MinValue = 0;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if ("Min Order Size" < 0) then
                    Error(MinOrderSizeErr);

                if ("Max Order Size" <> 0) and ("Min Order Size" > "Max Order Size") then
                    Error(OrderSizeRangeErr);
            end;
        }

        field(5; "Max Order Size"; Decimal)
        {
            Caption = 'Maximum Order Size';
            MinValue = 0;
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if ("Max Order Size" < 0) then
                    Error(MaxOrderSizeErr);

                if ("Max Order Size" <> 0) and ("Min Order Size" > "Max Order Size") then
                    Error(OrderSizeRangeErr);
            end;
        }

        field(6; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            TableRelation = "Production BOM Header";

            trigger OnValidate()
            var
                ProdBOMHeader: Record "Production BOM Header";
            begin
                if "Production BOM No." <> '' then
                    if not ProdBOMHeader.Get("Production BOM No.") then
                        Error(ProdBOMNotFoundErr, "Production BOM No.");
            end;
        }
    }

    keys
    {
        key(PK; "Item No.", "Variant Code", "Location Code", "Min Order Size")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ValidateData();
    end;

    trigger OnModify()
    begin
        ValidateData();
    end;

    var
        ItemMustBeMTSErr: Label 'Item %1 must be Make-to-Stock';
        ItemNotFoundErr: Label 'Item %1 does not exist';
        VariantNotFoundErr: Label 'Variant %1 does not exist for item %2';
        LocationNotFoundErr: Label 'Location %1 does not exist';
        ProdBOMNotFoundErr: Label 'Production BOM %1 does not exist';
        MinOrderSizeErr: Label 'Minimum Order Size cannot be negative';
        MaxOrderSizeErr: Label 'Maximum Order Size cannot be negative';
        OrderSizeRangeErr: Label 'Minimum Order Size must be less than Maximum Order Size';

    local procedure ValidateData()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
        ProdBOMHeader: Record "Production BOM Header";
    begin
        // Validate Item
        if not Item.Get("Item No.") then
            Error(ItemNotFoundErr, "Item No.");

        if Item."Manufacturing Policy" <> Item."Manufacturing Policy"::"Make-to-Stock" then
            Error(ItemMustBeMTSErr, "Item No.");

        // Validate Variant if specified
        if "Variant Code" <> '' then
            if not ItemVariant.Get("Item No.", "Variant Code") then
                Error(VariantNotFoundErr, "Variant Code", "Item No.");

        // Validate Location if specified
        if "Location Code" <> '' then
            if not Location.Get("Location Code") then
                Error(LocationNotFoundErr, "Location Code");

        // Validate Production BOM
        if "Production BOM No." <> '' then
            if not ProdBOMHeader.Get("Production BOM No.") then
                Error(ProdBOMNotFoundErr, "Production BOM No.");

        // Validate Order Sizes
        if ("Min Order Size" < 0) then
            Error(MinOrderSizeErr);

        if ("Max Order Size" < 0) then
            Error(MaxOrderSizeErr);

        if ("Max Order Size" <> 0) and ("Min Order Size" > "Max Order Size") then
            Error(OrderSizeRangeErr);
    end;
}