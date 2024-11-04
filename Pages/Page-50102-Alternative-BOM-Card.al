page 50102 "Alternative Prod. BOM Card"
{
    PageType = Card;
    ApplicationArea = Manufacturing;
    UsageCategory = None;
    SourceTable = "Alternative Prod. BOM";
    Caption = 'Alternative Production BOM Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the item number that this alternative BOM is for.';
                    Importance = Promoted;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                    begin
                        Item.SetRange("Manufacturing Policy", Item."Manufacturing Policy"::"Make-to-Stock");
                        if Page.RunModal(Page::"Item List", Item) = Action::LookupOK then
                            Rec.Validate("Item No.", Item."No.");
                    end;
                }

                field("Production BOM No."; Rec."Production BOM No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the alternative production BOM number.';
                    Importance = Promoted;
                }
            }

            group(Details)
            {
                Caption = 'Details';
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the variant of the item.';
                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the location where this BOM will be used.';
                }

                field("Min Order Size"; Rec."Min Order Size")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the minimum order size for using this BOM.';
                }

                field("Max Order Size"; Rec."Max Order Size")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the maximum order size for using this BOM.';
                }
            }
        }
        area(FactBoxes)
        {
            part(ItemPicture; "Item Picture")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "No." = FIELD("Item No.");
            }
            part("BOM Line"; "Production BOM Lines")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "Production BOM No." = FIELD("Production BOM No.");
                UpdatePropagation = SubPart;
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Item)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Item';
                Image = Item;
                RunObject = Page "Item Card";
                RunPageLink = "No." = FIELD("Item No.");
                ToolTip = 'View or edit detailed information about the item.';
            }
            action(ProductionBOM)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Production BOM';
                Image = BOM;
                RunObject = Page "Production BOM";
                RunPageLink = "No." = FIELD("Production BOM No.");
                ToolTip = 'View or edit the alternative production BOM.';
            }
        }
    }
}