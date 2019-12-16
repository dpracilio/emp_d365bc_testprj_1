tableextension 50110 "ICS Project Job" extends Job
{
    fields
    {
        field(50110; "ICS Project Status"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Planning,Open,"In Process","On Hold",Completed;
        }
        field(50111; "ICS Department"; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }
}