pageextension 50115 "Fin. Perform. Bus-Mgr. RC" extends "Business Manager Role Center"
{
    layout
    {
        addafter(Control55)
        {
            part(FinPerformance; "Fin. Perform. Analysis Chart")
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