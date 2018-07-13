 function beam_data = find_beam_data(prev_data, const, sigma_br)
    f = prev_data.f3;
    g = prev_data.f4;
    g(end) = g(end) + sigma_br(2);
    I = sparse(length(g), length(g));
    I(end, end) = 1;
    
    theta = @(w) const.B33\(f-const.B34*w);
    F = @(w) const.B43*theta(w) + const.B44*w+N(w, const)-g ... 
        -[zeros(length(g)-1, 1); sigma_br(1)*w(end)];
    C = const.jac_term - sigma_br(1)*I; % constant term of jacobian
    JF = @(w) C + 1/2*const.rho*(2*(const.Kb*w)*(const.Kb*w)' ... 
        +(w'*const.Kb*w)*const.Kb);
    
    beam_data.w = newtons_method(prev_data.w, 10^(-6), F, JF);
    beam_data.theta = theta(beam_data.w);