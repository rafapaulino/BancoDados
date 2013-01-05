//
//  DatabaseHandler.m
//  SQlite
//
//  Created by Luiz Gustavo Lino on 4/29/10.
//  Copyright 2010 tsubasa software inc.. All rights reserved.
//

#import "DatabaseHandler.h"


@implementation DatabaseHandler


static DatabaseHandler *_shared = nil;

+ (DatabaseHandler *)shared
{
	@synchronized([DatabaseHandler class])
    {
		if (!_shared) 
        {
			_shared = [[self alloc] init];
		}
	}
    
	return _shared;
}

- (id)init
{
    self = [super init];
    
    if (self != nil) 
    {
		[self open];
    }
    
    return self;
}

//retorna 1 se tiver feito a insercao e 0 se nao tiver feito a insercao
-(int)adicionarConteudoComSQL:(NSString*)sql
{
    sqlite3_stmt *resultado = [self runSQL:sql];
    
    if (resultado != nil) 
    {
        return 1;
    }
    else
    {
        return 0;
    }
    
}


//retorna 1 se tiver deletado o conteudo e 0 se nao tiver deletado o conteudo
-(int)excluirConteudoComSQL:(NSString*)sql
{
    sqlite3_stmt *resultado = [self runSQL:sql];
    
    if (resultado != nil) 
    {
        return 1;
    }
    else
    {
        return 0;
    }
    
}

//retorna 1 se tiver atualizado o conteudo e 0 se nao tiver atualizado o conteudo
-(int)atualizarConteudoComSQL:(NSString*)sql
{
    sqlite3_stmt *resultado = [self runSQL:sql];
    
    if (resultado != nil) 
    {
        return 1;
    }
    else
    {
        return 0;
    }
    
}

-(int)retornarNumeroDeRegistros:(NSString*)tabela
{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@", tabela];
    
    sqlite3_stmt *resposta = [self runSQL:sql];
    
    int linhas = 0;
    
    if (sqlite3_step(resposta) == SQLITE_ROW) 
    {
        linhas = sqlite3_column_int(resposta, 0);
    }
    
    return linhas;
}

//retorna 1 se tiver atualizado o conteudo e 0 se nao tiver atualizado o conteudo
-(NSArray*)buscarConteudoComSQL:(NSString*)sql
{
    sqlite3_stmt *resultado = [self runSQL:sql];
    
    NSString *tipoFrom;
    NSString *tipoSelect;
    
    if ([sql rangeOfString:@"FROM"].location != NSNotFound) 
    {
        tipoFrom = @"FROM";
    }
    else if ([sql rangeOfString:@"from"].location != NSNotFound)
    {
        tipoFrom = @"from";
    }
    
    if ([sql rangeOfString:@"SELECT"].location != NSNotFound) 
    {
        tipoSelect = @"SELECT";
    }
    else if ([sql rangeOfString:@"select"].location != NSNotFound)
    {
        tipoSelect = @"select";
    }
    
    NSArray *recebeParteInicialSQL = [sql componentsSeparatedByString:tipoFrom];
    NSArray *recebeParteInicialSemSELECT = [[recebeParteInicialSQL objectAtIndex:0] componentsSeparatedByString:tipoSelect];
    
    NSString *stringCampos = [recebeParteInicialSemSELECT objectAtIndex:1];
    NSString *camposSemEspacos = [stringCampos stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray *campos = [camposSemEspacos componentsSeparatedByString:@","];
    
    //vetor onde são armazenadas as dicas
	NSMutableArray *recebeLinhas = [[NSMutableArray alloc] init];
	
    NSString *recebeLinha;
		
	while(sqlite3_step(resultado) == SQLITE_ROW) 
    {
		
		NSMutableDictionary *linha = [[NSMutableDictionary alloc] init];
		
		const char *texto_c;
		
        for (int i = 0; i < [campos count]; i++) 
        {
            texto_c = (const char*) sqlite3_column_text(resultado, i);
            
            if (texto_c) 
            {
                recebeLinha = [NSString stringWithCString:texto_c encoding:NSUTF8StringEncoding];
            }
            
            [linha setObject:recebeLinha forKey:[campos objectAtIndex:i]];
        }
        
		[recebeLinhas addObject:linha];
	}
    
    return recebeLinhas;
    
}

-(sqlite3_stmt*) runSQL:(NSString*) isql{

	// alloc
	sqlite3_stmt *stmt;
	char *errmsg;
	const char *sql = [isql cStringUsingEncoding:NSUTF8StringEncoding];
	
	// prepare
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK) {
		NSLog(@"SQL Warning: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		return nil;
	}
	
	// execute
	if(sqlite3_exec(database, sql, nil, &stmt, &errmsg) == SQLITE_OK){
		return stmt;
	}else {
		NSLog(@"SQL Warning: '%s'.", sqlite3_errmsg(database));
		return nil;
	}
}

-(NSString*) path:(NSString*) filename{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0], *filepath;
	if (filename != nil) {
		filepath = [documentsDirectory stringByAppendingPathComponent:filename];
	}else{
		filepath = documentsDirectory;
	}
	return filepath;
}




- (void) runScript:(NSString*)path{
	NSError *err;
	NSString *script_path = [self resourcesFilePath:path] ;
	NSString *script = [[NSString alloc] initWithContentsOfFile:script_path encoding:NSUTF8StringEncoding error:&err];
	if(script != nil) [self runSQL:script];
	else NSLog(@"erro: %@", [err description]);
	
}

-(NSString*) resourcesFilePath:(NSString*) filename{
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
}

- (BOOL) open{
	const char *path = [[self path:@"db.sql"] cStringUsingEncoding:NSUTF8StringEncoding];
	NSLog(@"Path Banco:%s",path);
	return (sqlite3_open(path, &database) == SQLITE_OK) ? YES	: NO ;
}



@end
