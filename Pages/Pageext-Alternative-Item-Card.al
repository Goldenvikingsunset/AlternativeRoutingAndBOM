pageextension 50102 "Item Card Ext" extends "Item Card"
{
    layout
    {
        addlast(factboxes)
        {
            part(AltBOMsFactBox; "Alt. BOMs FactBox")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "Item No." = FIELD("No.");
                UpdatePropagation = SubPart;
            }
            part(AltRoutingsFactBox; "Alt. Routings FactBox")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "Item No." = FIELD("No.");
                UpdatePropagation = SubPart;
            }
        }
    }

    actions
    {
        addafter("BOM Level")
        {
            action(AlternativeBOMs)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Alternative BOMs';
                Image = BOMVersions;
                RunObject = Page "Alternative Prod. BOM List";
                RunPageLink = "Item No." = FIELD("No.");
                ToolTip = 'View or edit alternative BOMs for this item.';
                Promoted = true;
                PromotedCategory = Category8;
                PromotedIsBig = true;
            }
            action(AlternativeRoutings)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Alternative Routings';
                Image = Route;
                RunObject = Page "Alternative Routing List";
                RunPageLink = "Item No." = FIELD("No.");
                ToolTip = 'View or edit alternative routings for this item.';
                Promoted = true;
                PromotedCategory = Category8;
                PromotedIsBig = true;
            }
        }
    }
}