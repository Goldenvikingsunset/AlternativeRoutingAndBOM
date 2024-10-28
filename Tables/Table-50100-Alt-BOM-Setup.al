table 50100 "Alternative Prod. BOM"
{
    Caption = 'Alternative Production BOM';
    DataClassification = CustomerContent;
    //LookupPageId = "Alternative Prod. BOM List";
    //DrillDownPageId = "Alternative Prod. BOM List";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            NotBlank = true;

            trigger OnValidate()
            begin
                if "Item No." <> xRec."Item No." then begin
                    "Production BOM No." := '';
                    "Variant Code" := '';
                end;
            end;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));

            trigger OnValidate()
            begin
                TestField("Item No.");
            end;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;

            trigger OnValidate()
            begin
                TestField("Item No.");
            end;
        }
        field(4; "Min Order Size"; Decimal)
        {
            Caption = 'Minimum Order Size';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Min Order Size" > "Max Order Size" then
                    Error(MinGreaterThanMaxErr);
            end;
        }
        field(5; "Max Order Size"; Decimal)
        {
            Caption = 'Maximum Order Size';
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Min Order Size" > "Max Order Size" then
                    Error(MinGreaterThanMaxErr);
            end;
        }
        field(6; "Production BOM No."; Code[20])
        {
            Caption = 'Production BOM No.';
            TableRelation = "Production BOM Header"."No." WHERE(Status = CONST(Certified));

            trigger OnValidate()
            begin
                TestField("Item No.");
                if "Production BOM No." <> '' then
                    ValidateProductionBOM();
            end;
        }
        field(7; "Starting Date"; Date)
        {
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                ValidateDateRange();
            end;
        }
        field(8; "Ending Date"; Date)
        {
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                ValidateDateRange();
            end;
        }
        field(9; Status; Enum "Alternative Status")
        {
            Caption = 'Status';
            InitValue = New;
        }
    }

    keys
    {
        key(PK; "Item No.", "Variant Code", "Location Code", "Starting Date")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Production BOM No.")
        {
        }
        key(Key3; "Production BOM No.")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Item No.", "Variant Code", "Location Code", "Production BOM No.")
        {
        }
    }

    var
        MinGreaterThanMaxErr: Label 'Minimum Order Size cannot be greater than Maximum Order Size.';
        DateRangeErr: Label 'Starting Date must be before Ending Date.';
        DuplicateErr: Label 'An alternative BOM with overlapping dates already exists for this item, variant, and location.';

    trigger OnInsert()
    begin
        TestField("Item No.");
        TestField("Production BOM No.");
        ValidateDuplicates();
    end;

    local procedure ValidateProductionBOM()
    var
        ProdBOMHeader: Record "Production BOM Header";
        Item: Record Item;
    begin
        if not ProdBOMHeader.Get("Production BOM No.") then
            Error('Production BOM %1 does not exist.', "Production BOM No.");

        if ProdBOMHeader.Status <> ProdBOMHeader.Status::Certified then
            Error('Production BOM %1 must be certified.', "Production BOM No.");

        if Item.Get("Item No.") then
            if Item."Production BOM No." = "Production BOM No." then
                Error('This is already the standard Production BOM for the item.');
    end;

    local procedure ValidateDateRange()
    begin
        if ("Starting Date" <> 0D) and ("Ending Date" <> 0D) then
            if "Starting Date" > "Ending Date" then
                Error(DateRangeErr);
    end;

    local procedure ValidateDuplicates()
    var
        AltProdBOM: Record "Alternative Prod. BOM";
    begin
        AltProdBOM.SetRange("Item No.", "Item No.");
        AltProdBOM.SetRange("Variant Code", "Variant Code");
        AltProdBOM.SetRange("Location Code", "Location Code");
        AltProdBOM.SetFilter("Starting Date", '<=%1', "Ending Date");
        AltProdBOM.SetFilter("Ending Date", '>=%1', "Starting Date");
        if not AltProdBOM.IsEmpty then
            Error(DuplicateErr);
    end;
}