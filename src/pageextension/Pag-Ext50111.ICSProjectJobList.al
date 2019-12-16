pageextension 50111 "ICS Project Job List" extends "Job List"
{
    layout
    {
        addfirst(factboxes)
        {
            // part("ICS Project Analysis Chart"; "ICS Project Analysis Chart")
            // {
            //     ApplicationArea = All;
            // }
            part("Jobs By Posting Group Chart"; "Jobs By Posting Group Chart")
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