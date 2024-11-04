page 50100 "Alternative Prod. BOM List"
{
    PageType = List;
    ApplicationArea = Manufacturing;
    UsageCategory = Lists;
    SourceTable = "Alternative Prod. BOM";
    Caption = 'Alternative Production BOMs';
    //CardPageId = "Alternative Prod. BOM Card";
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
                    ToolTip = 'Specifies the item number that this alternative BOM is for.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Item: Record Item;
                    begin
                        Item.SetRange("Manufacturing Policy", Item."Manufacturing Policy"::"Make-to-Stock");
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

                field("Production BOM No."; Rec."Production BOM No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the alternative production BOM number.';
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
        area(Processing)
        {
            action(CopyBOM)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Copy BOM';
                Image = Copy;
                ToolTip = 'Copy an existing alternative BOM to create a new one.';

                trigger OnAction()
                var
                    AltProdBOM: Record "Alternative Prod. BOM";
                begin
                    AltProdBOM.Copy(Rec);
                    AltProdBOM.Insert(true);
                end;
            }
        }
    }
}