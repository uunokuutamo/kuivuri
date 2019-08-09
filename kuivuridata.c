
#include <stdio.h>
#include <postgresql/libpq-fe.h>
#include <string.h>
#include <stdlib.h>

 
void main() {	
	int row;
//	int col;
	int rec_count;
	PGconn          *conn;
	PGresult        *res;

	conn = PQconnectdb("dbname=kuivuri user=dt password=dt");
	// conn = PQconnectdb("dbname=oyab host=localhost user=web password=web");
 
	if (PQstatus(conn) == CONNECTION_BAD) {
		puts("We were unable to connect to the database");
		exit(0);
	}
  
	res = PQexec(conn, "select ts, ulko, meno, paluu from viim10 order by ts DESC");
         
	if (PQresultStatus(res) != PGRES_TUPLES_OK) {
		puts("We did not get any data!");
		exit(0);
}
	rec_count = PQntuples(res);        
      
	// printf( "We received %d records.\n", rec_count);

	for (row=0; row<rec_count; row++) {
	//	printf("\t");
		// for (col=0; col<4; col++) {
			// printf("<td>%s</td>", PQgetvalue(res, row, col));
			printf("%s", PQgetvalue(res, row, 0));
			printf("\t%s", PQgetvalue(res, row, 1));
			printf("\t%s", PQgetvalue(res, row, 2));
			printf("\t%s", PQgetvalue(res, row, 3));
		// }
		printf("\n");        
	}

	puts("");

	PQclear(res);
	PQfinish(conn); 

}

