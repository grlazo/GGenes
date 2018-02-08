$(document).ready( function () {
    //$('#dataTable').DataTable();
    $('#dataTable').DataTable( {
    /*"sDom": '<"top">rt',
"sDom": '<plf<t>ti>',*/
"sDom": 'ip<"top">rft<"bottom"l><"clear">',
"iDisplayLength": 25,
    colReorder: true
    } );
    // Setup - add a text input to each footer cell
    $('#dataTable tfoot th').each( function () {
        var title = $('#dataTable thead th').eq( $(this).index() ).text();
        $(this).html( '<input type="text" placeholder="Search '+title+'" />' );
    } );
 
    // DataTable
    var table = $('#dataTable').DataTable();
 
    // Apply the search
    table.columns().every( function () {
        var that = this;
 
        $( 'input', this.footer() ).on( 'keyup change', function () {
            if ( that.search() !== this.value ) {
                that
                    .search( this.value )
                    .draw();
            }
        } );
    } );

} );
