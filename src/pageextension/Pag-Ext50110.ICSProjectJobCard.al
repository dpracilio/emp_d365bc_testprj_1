pageextension 50110 "ICS Project Job Card" extends "Job Card"
{
    layout
    {
        addlast(General)
        {
            field("ICS Department"; "ICS Department")
            {
                ApplicationArea = All;
            }
            field("ICS Project Status"; "ICS Project Status")
            {
                ApplicationArea = All;
            }
        }
    }

}