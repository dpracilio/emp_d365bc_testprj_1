table 50115 "Fin. Perform. Chart Setup"
{
    Caption = 'Financial Performance Chart Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "User ID"; Text[132])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(2; "Period Length"; Option)
        {
            Caption = 'Period Length';
            OptionCaption = 'Day,Week,Month,Quarter,Year';
            OptionMembers = Day,Week,Month,Quarter,Year;
            DataClassification = CustomerContent;
        }
        field(4; "Start Date"; Option)
        {
            Caption = 'Start Date';
            OptionCaption = 'First Entry Date,Working Date';
            OptionMembers = "First Entry Date","Working Date";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "User ID")
        {
            Clustered = true;
        }
    }

    procedure SetPeriodLength(PeriodLength: Option)
    begin
        "Period Length" := PeriodLength;
        Modify;
    end;

}