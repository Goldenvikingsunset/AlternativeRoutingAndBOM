page 50104 "Alt. BOMs FactBox"
{
    Caption = 'Alternative BOMs';
    PageType = ListPart;
    SourceTable = "Alternative Prod. BOM";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(VariantCode; Rec."Variant Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the variant code.';
                }
                field(LocationCode; Rec."Location Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the location code.';
                }
                field(ProdBOMNo; Rec."Production BOM No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the production BOM number.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        ProdBOMHeader: Record "Production BOM Header";
                    begin
                        if ProdBOMHeader.Get(Rec."Production BOM No.") then
                            Page.Run(Page::"Production BOM", ProdBOMHeader);
                    end;
                }
                field(MinOrderSize; Rec."Min Order Size")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the minimum order size.';
                }
                field(MaxOrderSize; Rec."Max Order Size")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the maximum order size.';
                }
            }
        }
    }
}