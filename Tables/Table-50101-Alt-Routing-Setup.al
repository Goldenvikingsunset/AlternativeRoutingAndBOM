table 50101 "Alternative Routing"
{
    Caption = 'Alternative Routing';
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

                    if Item."Routing No." = '' then
                        Error(ItemNoRoutingErr, "Item No.");
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
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if "Location Code" <> '' then begin
                    Location.Get("Location Code");
                    if Location."Use As In-Transit" then
                        Error(LocationInTransitErr, "Location Code");
                end;
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

        field(6; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            TableRelation = "Routing Header";
            NotBlank = true;

            trigger OnValidate()
            var
                RoutingHeader: Record "Routing Header";
                Item: Record Item;
            begin
                if "Routing No." <> '' then begin
                    if not RoutingHeader.Get("Routing No.") then
                        Error(RoutingNotFoundErr, "Routing No.");

                    // Validate routing status
                    if RoutingHeader.Status <> RoutingHeader.Status::Certified then
                        Error(RoutingNotCertifiedErr, "Routing No.");

                    // Check if routing matches item's manufacturing setup
                    if Item.Get("Item No.") then begin
                        if (Item."Routing No." <> '') and (Item."Routing No." = "Routing No.") then
                            Error(RoutingIsDefaultErr, "Routing No.", "Item No.");
                    end;
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Item No.", "Variant Code", "Location Code", "Min Order Size")
        {
            Clustered = true;
        }
        key(Routing; "Routing No.")
        {
            // Secondary key for routing lookups
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
        ItemNoRoutingErr: Label 'Item %1 must have a standard routing defined';
        VariantNotFoundErr: Label 'Variant %1 does not exist for item %2';
        LocationNotFoundErr: Label 'Location %1 does not exist';
        LocationInTransitErr: Label 'Location %1 cannot be an in-transit location';
        RoutingNotFoundErr: Label 'Routing %1 does not exist';
        RoutingNotCertifiedErr: Label 'Routing %1 must be certified before it can be used';
        RoutingIsDefaultErr: Label 'Routing %1 is already the default routing for item %2';
        MinOrderSizeErr: Label 'Minimum Order Size cannot be negative';
        MaxOrderSizeErr: Label 'Maximum Order Size cannot be negative';
        OrderSizeRangeErr: Label 'Minimum Order Size must be less than Maximum Order Size';

    local procedure ValidateData()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
        RoutingHeader: Record "Routing Header";
    begin
        // Validate Item
        if not Item.Get("Item No.") then
            Error(ItemNotFoundErr, "Item No.");

        if Item."Manufacturing Policy" <> Item."Manufacturing Policy"::"Make-to-Stock" then
            Error(ItemMustBeMTSErr, "Item No.");

        if Item."Routing No." = '' then
            Error(ItemNoRoutingErr, "Item No.");

        // Validate Variant if specified
        if "Variant Code" <> '' then
            if not ItemVariant.Get("Item No.", "Variant Code") then
                Error(VariantNotFoundErr, "Variant Code", "Item No.");

        // Validate Location if specified
        if "Location Code" <> '' then begin
            Location.Get("Location Code");
            if Location."Use As In-Transit" then
                Error(LocationInTransitErr, "Location Code");
        end;

        // Validate Routing
        if "Routing No." <> '' then begin
            if not RoutingHeader.Get("Routing No.") then
                Error(RoutingNotFoundErr, "Routing No.");

            if RoutingHeader.Status <> RoutingHeader.Status::Certified then
                Error(RoutingNotCertifiedErr, "Routing No.");

            if (Item."Routing No." <> '') and (Item."Routing No." = "Routing No.") then
                Error(RoutingIsDefaultErr, "Routing No.", "Item No.");
        end;

        // Validate Order Sizes
        if ("Min Order Size" < 0) then
            Error(MinOrderSizeErr);

        if ("Max Order Size" < 0) then
            Error(MaxOrderSizeErr);

        if ("Max Order Size" <> 0) and ("Min Order Size" > "Max Order Size") then
            Error(OrderSizeRangeErr);
    end;
}