page 50105 "Alt. Routings FactBox"
{
    Caption = 'Alternative Routings';
    PageType = ListPart;
    SourceTable = "Alternative Routing";
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
                field(RoutingNo; Rec."Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the routing number.';
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        RoutingHeader: Record "Routing Header";
                    begin
                        if RoutingHeader.Get(Rec."Routing No.") then
                            Page.Run(Page::Routing, RoutingHeader);
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