page 59001 "Tractor Entity"
{
    PageType = API;
    SourceTable = Tractor;
    Caption = 'tractors';
    APIGroup = 'custom';
    APIPublisher = 'Empired';
    APIVersion = 'v1.0';
    EntityName = 'tractor';
    EntitySetName = 'tractors';
    DelayedInsert = true;
    ODataKeyFields = Id;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Id; Id)
                {
                    Caption = 'Id';
                    ApplicationArea = All;
                }
                field(code; Code)
                {
                    Caption = 'code';
                    ApplicationArea = All;
                }
                field(description; Description)
                {
                    Caption = 'description';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Insert(true);
        Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Tractor: Record Tractor;
    begin
        Tractor.SetRange(Id, Id);
        Tractor.FindFirst();

        if Code <> Tractor.Code then begin
            Tractor.TransferFields(Rec, false);
            Tractor.Rename(Code);
            TransferFields(Tractor);
        end;
    end;
}