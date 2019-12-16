pageextension 50112 "Jobs By Post. Grp. Bus-Mgr. RC" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control55)
        {
            part(Jb; "Jobs By Posting Group Chart")
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