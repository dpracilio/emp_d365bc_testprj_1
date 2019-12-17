pageextension 50112 "Jobs By Post. Grp. Bus-Mgr. RC" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control55)
        {
            part(JobPerformance; "Job Performance Chart Wrapper")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}