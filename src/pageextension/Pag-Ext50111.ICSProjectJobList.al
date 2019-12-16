pageextension 50111 "ICS Project Job List" extends "Job List"
{
    layout
    {
        addfirst(factboxes)
        {
            part("ICS Project Analysis Chart"; "ICS Project Analysis Chart")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {

    }

    trigger OnAfterGetRecord()
    begin

    end;
}