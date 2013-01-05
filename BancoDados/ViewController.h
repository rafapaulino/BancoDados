//
//  ViewController.h
//  BancoDados
//
//  Created by Rafael Brigagão Paulino on 04/10/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITextField *autor;
@property (nonatomic, weak) IBOutlet UITextField *titulo;
@property (nonatomic, weak) IBOutlet UITextField *preco;
@property (nonatomic, weak) IBOutlet UITextField *ano;

@property (nonatomic, weak) IBOutlet UITableView *tabela;

-(IBAction)inserirNovoLivroClicado:(id)sender;
-(void)buscarDadosAtualizados;


@end
