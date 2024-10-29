table 50101 "Alternative Routing"
{
    Caption = 'Alternative Routing';
    DataClassification = CustomerContent;
    //LookupPageId = "Alternative Routing List";
    //DrillDownPageId = "Alternative Routing List";

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
                    "Routing No." := '';
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
        field(6; "Routing No."; Code[20])
        {
            Caption = 'Routing No.';
            TableRelation = "Routing Header"."No." WHERE(Status = CONST(Certified));

            trigger OnValidate()
            begin
                TestField("Item No.");
                if "Routing No." <> '' then
                    ValidateRouting();
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
        field(10; "Work Center Filter"; Code[20])
        {
            Caption = 'Work Center Filter';
            TableRelation = "Work Center";

            trigger OnValidate()
            begin
                if "Work Center Filter" <> '' then
                    ValidateWorkCenter();
            end;
        }
    }

    keys
    {
        key(PK; "Item No.", "Variant Code", "Location Code", "Starting Date")
        {
            Clustered = true;
        }
        key(Key2; "Item No.", "Routing No.")
        {
        }
        key(Key3; "Routing No.")
        {
        }
        key(Key4; "Work Center Filter")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Item No.", "Variant Code", "Location Code", "Routing No.")
        {
        }
    }

    var
        MinGreaterThanMaxErr: Label 'Minimum Order Size cannot be greater than Maximum Order Size.';
        DateRangeErr: Label 'Starting Date must be before Ending Date.';
        DuplicateErr: Label 'An alternative routing with overlapping dates already exists for this item, variant, and location.';
        WorkCenterNotInRoutingErr: Label 'The selected Work Center must be used in the Routing operations.';
        RoutingNotExistErr: Label 'Routing %1 does not exist.';
        RoutingNotCertifiedErr: Label 'Routing %1 must be certified.';
        StandardRoutingErr: Label 'This is already the standard Routing for the item.';

    trigger OnInsert()
    begin
        TestField("Item No.");
        TestField("Routing No.");
        ValidateDuplicates();
    end;

    local procedure ValidateRouting()
    var
        RoutingHeader: Record "Routing Header";
        Item: Record Item;
    begin
        if not RoutingHeader.Get("Routing No.") then
            Error(RoutingNotExistErr, "Routing No.");

        if RoutingHeader.Status <> RoutingHeader.Status::Certified then
            Error(RoutingNotCertifiedErr, "Routing No.");

        if Item.Get("Item No.") then
            if Item."Routing No." = "Routing No." then
                Error(StandardRoutingErr);
    end;

    local procedure ValidateDateRange()
    begin
        if ("Starting Date" <> 0D) and ("Ending Date" <> 0D) then
            if "Starting Date" > "Ending Date" then
                Error(DateRangeErr);
    end;

    local procedure ValidateDuplicates()
    var
        AltRouting: Record "Alternative Routing";
    begin
        AltRouting.SetRange("Item No.", "Item No.");
        AltRouting.SetRange("Variant Code", "Variant Code");
        AltRouting.SetRange("Location Code", "Location Code");
        AltRouting.SetFilter("Starting Date", '<=%1', "Ending Date");
        AltRouting.SetFilter("Ending Date", '>=%1', "Starting Date");
        if not AltRouting.IsEmpty then
            Error(DuplicateErr);
    end;

    local procedure ValidateWorkCenter()
    var
        RoutingLine: Record "Routing Line";
    begin
        if "Routing No." = '' then
            exit;

        RoutingLine.SetRange("Routing No.", "Routing No.");
        RoutingLine.SetRange("Work Center No.", "Work Center Filter");
        if RoutingLine.IsEmpty then
            Error(WorkCenterNotInRoutingErr);
    end;
}