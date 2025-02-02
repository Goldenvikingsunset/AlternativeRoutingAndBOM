page 50101 "Alternative Routing List"
{
    PageType = List;
    ApplicationArea = Manufacturing;
    UsageCategory = Lists;
    SourceTable = "Alternative Routing";
    Caption = 'Alternative Routings';
    //CardPageId = "Alternative Routing Card";
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the item number that this alternative routing is for.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                    begin
                        Item.SetRange("Manufacturing Policy", Item."Manufacturing Policy"::"Make-to-Stock");
                        Item.SetFilter("Routing No.", '<>%1', '');  // Only items with routing
                        if Page.RunModal(Page::"Item List", Item) = Action::LookupOK then
                            Rec.Validate("Item No.", Item."No.");
                    end;
                }

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

                field("Routing No."; Rec."Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the alternative routing number.';
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
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
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
        area(Processing)
        {
            action(CopyRouting)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Copy Routing';
                Image = Copy;
                ToolTip = 'Copy an existing alternative routing to create a new one.';

                trigger OnAction()
                var
                    AltRouting: Record "Alternative Routing";
                begin
                    AltRouting.Copy(Rec);
                    AltRouting.Insert(true);
                end;
            }
        }
    }
}