table 59000 "Tractor"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {

        }
        field(2; "Description"; Text[250])
        {

        }
        field(8000; Id; Guid)
        {

        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    begin
        Id := CreateGuid();
    end;

    // procedure Update()
    // var
    //     CallWebService: Codeunit
    // begin
    //     CallWebService..
    // end;

}