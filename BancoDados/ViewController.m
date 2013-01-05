//
//  ViewController.m
//  BancoDados
//
//  Created by Rafael Brigagão Paulino on 04/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "ViewController.h"
#import "DatabaseHandler.h"

@interface ViewController ()
{
    //esse array vai receber os registros resultantes do select e tb vai ser o datasouce da tableview
    NSArray *listaLivros;
    
    //toda vez que alterar o vetor, precisamos alterar a tableview visualmente
    
}

@end

@implementation ViewController

#pragma mark Metodos default

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self buscarDadosAtualizados];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark Metodos da tabela

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return listaLivros.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *idCelula = @"minhaCelula";
    
    UITableViewCell *celula = [tableView dequeueReusableCellWithIdentifier:idCelula];
    
    if (celula == nil) {
        celula = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idCelula];
    }
    
    NSDictionary *dadosLivro = [listaLivros objectAtIndex:indexPath.row];
    
    //configurar celula
    celula.textLabel.text = [dadosLivro objectForKey:@"autor"];
    celula.detailTextLabel.text = [dadosLivro objectForKey:@"titulo"];
    
    return celula;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //apagar o registro que foi retirado da tela no banco de dados
        //preparar um sql de delete
        
        NSDictionary *livroExclusao = [listaLivros objectAtIndex:indexPath.row];
        
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM Livro WHERE id = %@",[livroExclusao objectForKey:@"id"]];
        
        int retorno = [[DatabaseHandler shared] excluirConteudoComSQL:sql];
        
        if (retorno == 0)
        {
            NSLog(@"exclusao falhou");
        }
        else
        {
            NSLog(@"o item foi excluido");
            
            
            [self buscarDadosAtualizados];
        }
        
        
    }
}


#pragma mark Inserir novo livro

-(IBAction)inserirNovoLivroClicado:(id)sender
{
    //validacao dos capos de texto
    //ano 4 digitos
    //preco deve ter . como separador decimal
    
    //substituindo virgulas por ponto
    _preco.text = [_preco.text stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    //experessoes regulares - expressoes para validacoes de conteudo
    NSString *expressao = @"^[0-9]{4}$";
    
    //predicate - criterio de validacao utilizar a expressao regular
    NSPredicate *validacao = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",expressao];
    
    //estou pegando o predicado criado e pedindo para que ele teste se o conteudo do campo de texto atende a expressao regular que queremos
    if ([validacao evaluateWithObject:_ano.text])
    {
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO Livro (titulo,autor,ano,preco) VALUES('%@', '%@', %@, %@)",_titulo.text, _autor.text, _ano.text, _preco.text];
        
        int retorno = [[DatabaseHandler shared] adicionarConteudoComSQL:sql];
        
        if (retorno == 0)
        {
            NSLog(@"insercao falhou");
        }
        else
        {
            NSLog(@"novo livro incluido na tabela");
            
            [self buscarDadosAtualizados];
        }
        
        //percorrendo todas as subviews na tela, e caso seja um textfield, eu faco o resign e limpo o conteudo
        for (UIView  *subview in self.view.subviews)
        {
            if ([subview isKindOfClass:[UITextField class]])
            {
                UITextField *esteCampo = (UITextField*)subview;
                [esteCampo resignFirstResponder];
                esteCampo.text = @"";
            }
        }
    }
    else
    {
        //caso a validacao do predicado tenha falhado
        [[[UIAlertView alloc] initWithTitle:@"Ops!" message:@"O campo ano deve ter 4 digitos" delegate:nil cancelButtonTitle:@"Fechar" otherButtonTitles: nil] show];
    }
    
}

#pragma mark Metodo buscar dados

-(void)buscarDadosAtualizados
{
    //montar o sql de select
    NSString *sql = @"SELECT id,titulo,autor,ano,preco FROM Livro ORDER BY titulo ASC";
    
    //solicictar ao databasehandler para acessar o banco de dados e executar o select
    listaLivros = [[DatabaseHandler shared] buscarConteudoComSQL:sql];
    
    NSLog(@"olha ae %@", listaLivros.description);
    
    [_tabela reloadData];
    
}

@end
