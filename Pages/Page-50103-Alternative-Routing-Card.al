page 50103 "Alternative Routing Card"
{
    PageType = Card;
    ApplicationArea = Manufacturing;
    UsageCategory = None;
    SourceTable = "Alternative Routing";
    Caption = 'Alternative Routing Card';

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
                    ToolTip = 'Specifies the item number that this alternative routing is for.';
                    Importance = Promoted;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                    begin
                        Item.SetRange("Manufacturing Policy", Item."Manufacturing Policy"::"Make-to-Stock");
                        Item.SetFilter("Routing No.", '<>%1', '');
                        if Page.RunModal(Page::"Item List", Item) = Action::LookupOK then
                            Rec.Validate("Item No.", Item."No.");
                    end;
                }

                field("Routing No."; Rec."Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the alternative routing number.';
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
                    ToolTip = 'Specifies the location where this routing will be used.';
                }

                field("Min Order Size"; Rec."Min Order Size")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the minimum order size for using this routing.';
                }

                field("Max Order Size"; Rec."Max Order Size")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the maximum order size for using this routing.';
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
            part("Routing Lines"; "Routing Lines")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "Routing No." = FIELD("Routing No.");
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
            action(Routing)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Routing';
                Image = Route;
                RunObject = Page "Routing";
                RunPageLink = "No." = FIELD("Routing No.");
                ToolTip = 'View or edit the alternative routing.';
            }
        }
    }
}