//
//  DatabaseHandler.h
//  SQlite
//
//  Created by Luiz Gustavo Lino on 4/29/10.
//  Copyright 2010 tsubasa software inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface DatabaseHandler : NSObject {
	sqlite3 *database;
}

+ (DatabaseHandler *)shared;
-(int)adicionarConteudoComSQL:(NSString*)sql;
-(int)excluirConteudoComSQL:(NSString*)sql;
-(int)atualizarConteudoComSQL:(NSString*)sql;
-(int)retornarNumeroDeRegistros:(NSString*)tabela;
-(NSArray*)buscarConteudoComSQL:(NSString*)sql;
- (sqlite3_stmt*) runSQL:(NSString*) isql;
- (BOOL) open;
- (void) runScript:(NSString*)path;
- (NSString*) resourcesFilePath:(NSString*) filename;

@end
